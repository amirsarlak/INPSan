#!/usr/bin/bash
# INPSan Control Plane v0.1.0-dev — live OmniOS validator
# Non-destructive: loopback-only dev service + read-only requests + /var/tmp evidence.

set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PL="$BASE/inpsan-control-plane-v0.1.0-dev.pl"
VERIFY="$BASE/verify.sh"
PORT=${INPSAN_CP_TEST_PORT:-18080}
STAMP=$(date '+%Y%m%d-%H%M%S')
OUT=${1:-/var/tmp/inpsan-control-plane-validation-${STAMP}}
mkdir -p "$OUT" || exit 1

CURL=$(command -v curl 2>/dev/null || true)
if [ -z "$CURL" ]; then
  echo 'curl is required for live validation.' | tee "$OUT/summary.txt"
  exit 2
fi

PASS=1
PID=''

cleanup() {
  if [ -n "$PID" ]; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "validation_version=0.1.0-dev" >"$OUT/summary.txt"
echo "captured_at=$(date '+%Y-%m-%dT%H:%M:%S%z')" >>"$OUT/summary.txt"
echo "port=$PORT" >>"$OUT/summary.txt"

bash "$VERIFY" >"$OUT/static-verify.txt" 2>&1 || PASS=0

/usr/bin/perl "$PL" --port "$PORT" >"$OUT/server.log" 2>&1 &
PID=$!
sleep 1

if ! kill -0 "$PID" 2>/dev/null; then
  echo 'server_start=FAIL' >>"$OUT/summary.txt"
  cat "$OUT/server.log" >>"$OUT/summary.txt"
  exit 1
fi
echo 'server_start=PASS' >>"$OUT/summary.txt"

get_ep() {
  name=$1
  path=$2
  body="$OUT/${name}.json"
  headers="$OUT/${name}.headers"
  code=$($CURL -sS -D "$headers" -o "$body" -w '%{http_code}' "http://127.0.0.1:${PORT}${path}" 2>"$OUT/${name}.curl.err" || echo 000)
  echo "${name}_http=$code" >>"$OUT/summary.txt"
  if [ "$code" != '200' ]; then PASS=0; fi
  /usr/bin/perl -MJSON::PP -0777 -e 'decode_json(<STDIN>); print "JSON=PASS\n"' <"$body" >"$OUT/${name}.jsoncheck" 2>&1 || PASS=0
}

get_ep product-version /api/v1/product/version
get_ep system-health /api/v1/system/health
get_ep storage-pools /api/v1/storage/pools

# Target-specific semantic checks.
/usr/bin/perl -MJSON::PP -0777 -e '
  $j=decode_json(<STDIN>);
  die "not ok\n" unless $j->{ok};
  die "wrong control plane\n" unless $j->{data}{control_plane} eq "0.1.0-dev";
  print "product_semantics=PASS\n";
' <"$OUT/product-version.json" >"$OUT/product-version.semantic" 2>&1 || PASS=0

/usr/bin/perl -MJSON::PP -0777 -e '
  $j=decode_json(<STDIN>);
  die "zpool source unavailable\n" unless $j->{data}{zpool_source_available};
  die "alert source unavailable\n" unless $j->{data}{alert_source_available};
  print "health_sources=PASS\n";
' <"$OUT/system-health.json" >"$OUT/system-health.semantic" 2>&1 || PASS=0

/usr/bin/perl -MJSON::PP -0777 -e '
  $j=decode_json(<STDIN>);
  die "no pools\n" unless ($j->{data}{count} || 0) > 0;
  print "pool_semantics=PASS\n";
' <"$OUT/storage-pools.json" >"$OUT/storage-pools.semantic" 2>&1 || PASS=0

post_code=$($CURL -sS -o "$OUT/post-test.json" -w '%{http_code}' -X POST "http://127.0.0.1:${PORT}/api/v1/system/health" 2>"$OUT/post-test.err" || echo 000)
echo "post_http=$post_code" >>"$OUT/summary.txt"
[ "$post_code" = '405' ] || PASS=0

unknown_code=$($CURL -sS -o "$OUT/unknown-test.json" -w '%{http_code}' "http://127.0.0.1:${PORT}/api/v1/does-not-exist" 2>"$OUT/unknown-test.err" || echo 000)
echo "unknown_http=$unknown_code" >>"$OUT/summary.txt"
[ "$unknown_code" = '404' ] || PASS=0

cleanup
PID=''

if [ "$PASS" -eq 1 ]; then
  echo 'validation=PASS' >>"$OUT/summary.txt"
  echo "INPSan Control Plane live validation: PASS"
else
  echo 'validation=FAIL' >>"$OUT/summary.txt"
  echo "INPSan Control Plane live validation: FAIL"
fi

echo "Evidence directory: $OUT"
echo "Send summary.txt, product-version.json, system-health.json, storage-pools.json, static-verify.txt and server.log."

[ "$PASS" -eq 1 ]