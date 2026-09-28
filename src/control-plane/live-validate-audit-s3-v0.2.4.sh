#!/usr/bin/bash
# INPSan S3 live validation — Audit retention/query/health + performance
# Non-destructive, loopback-only, read-only storage access.
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"
CP="$BASE/inpsan-control-plane-v0.2.4-dev.pl"
VERIFY="$BASE/verify-audit-s3-v0.2.4.sh"
BENCH="$BASE/benchmark-audit-v0.2.4.sh"

PORT=18084
STAMP=$(date '+%Y%m%d-%H%M%S')
OUT="/var/tmp/inpsan-audit-s3-live-$STAMP"
STORE="$OUT/users.json"
AUDIT="$OUT/security-audit.jsonl"
SERVERLOG="$OUT/server.log"
SUMMARY="$OUT/summary.txt"

mkdir -p "$OUT" || exit 1
chmod 700 "$OUT" || exit 1

CURL=$(command -v curl 2>/dev/null || true)
if [ -z "$CURL" ]; then echo "curl_required=FAIL" | tee "$SUMMARY"; exit 2; fi

PASS=1
PID=''
cleanup() {
  if [ -n "$PID" ]; then kill "$PID" 2>/dev/null || true; wait "$PID" 2>/dev/null || true; fi
}
trap cleanup EXIT INT TERM

echo "test_suite=INPSan-S3-AUDIT-LIVE" >"$SUMMARY"
echo "captured_at=$(date '+%Y-%m-%dT%H:%M:%S%z')" >>"$SUMMARY"
echo "hostname=$(hostname)" >>"$SUMMARY"
echo "uname=$(uname -a)" >>"$SUMMARY"
echo "control_plane=v0.2.4-dev" >>"$SUMMARY"
echo "port=$PORT" >>"$SUMMARY"

bash "$VERIFY" >"$OUT/static-audit-s3.txt" 2>&1 || PASS=0
bash "$BENCH" >"$OUT/benchmark-audit.txt" 2>&1 || PASS=0

TESTPASS=$(/usr/bin/perl -MDigest::SHA=sha256_hex -e 'print substr(sha256_hex(rand().$$.time()),0,24),"Aa!7"')
export INPSAN_TESTPASS="$TESTPASS" INPSAN_TESTSTORE="$STORE"

/usr/bin/perl -I"$LIB" -MINPSan::Security::Auth -e '
  my $a=INPSan::Security::Auth->new(user_store=>$ENV{INPSAN_TESTSTORE});
  my $p=$ENV{INPSAN_TESTPASS};
  $a->create_user(username=>"s3_viewer",password=>$p,roles=>["viewer"],scopes=>["node:local"]);
  $a->create_user(username=>"s3_operator",password=>$p,roles=>["operator"],scopes=>["node:local"]);
  $a->create_user(username=>"s3_storage",password=>$p,roles=>["storage-admin"],scopes=>["node:local"]);
  $a->create_user(username=>"s3_security",password=>$p,roles=>["security-admin"],scopes=>["node:local"]);
  $a->create_user(username=>"s3_auditor",password=>$p,roles=>["auditor"],scopes=>["node:local"]);
  $a->create_user(username=>"s3_platform",password=>$p,roles=>["platform-admin"],scopes=>["node:local"]);
  print "user_provisioning=PASS\n";
' >"$OUT/user-provisioning.txt" 2>&1 || PASS=0

INPSAN_CP_USER_STORE="$STORE" INPSAN_CP_AUTH_AUDIT="$AUDIT"   /usr/bin/perl -I"$LIB" "$CP" --port "$PORT" --user-store "$STORE" --audit-log "$AUDIT"   >"$SERVERLOG" 2>&1 &
PID=$!
sleep 1

if ! kill -0 "$PID" 2>/dev/null; then
  echo "control_plane_start=FAIL" >>"$SUMMARY"
  exit 3
fi
echo "control_plane_start=PASS" >>"$SUMMARY"

login_user() {
  user="$1"; outfile="$2"
  $CURL -sS -o "$outfile" -w '%{http_code}'     -H 'Content-Type: application/json'     --data-binary "{\"username\":\"$user\",\"password\":\"$TESTPASS\"}"     "http://127.0.0.1:$PORT/api/v1/auth/login"
}

token_from() {
  /usr/bin/perl -MJSON::PP -0777 -e 'my $j=decode_json(<STDIN>); die unless $j->{ok} && $j->{data}{access_token}; print $j->{data}{access_token};' <"$1" 2>/dev/null
}

for USER in s3_viewer s3_operator s3_storage s3_security s3_auditor s3_platform; do
  LOGIN="$OUT/login-$USER.json"
  CODE=$(login_user "$USER" "$LOGIN")
  echo "$USER-login_http=$CODE" >>"$SUMMARY"
  [ "$CODE" = "200" ] || { PASS=0; continue; }

  TOKEN=$(token_from "$LOGIN")
  [ -n "$TOKEN" ] || { PASS=0; continue; }
  rm -f "$LOGIN"

  CODE=$($CURL -sS -o "$OUT/health-$USER.json" -w '%{http_code}'     -H "Authorization: Bearer $TOKEN"     "http://127.0.0.1:$PORT/api/v1/audit/health")
  echo "$USER-audit_health_http=$CODE" >>"$SUMMARY"

  case "$USER" in
    s3_security|s3_auditor|s3_platform) [ "$CODE" = "200" ] || PASS=0 ;;
    *) [ "$CODE" = "403" ] || PASS=0 ;;
  esac

  CODE=$($CURL -sS -o "$OUT/verify-$USER.json" -w '%{http_code}'     -H "Authorization: Bearer $TOKEN"     "http://127.0.0.1:$PORT/api/v1/audit/verify")
  echo "$USER-audit_verify_http=$CODE" >>"$SUMMARY"

  case "$USER" in
    s3_security|s3_auditor|s3_platform) [ "$CODE" = "200" ] || PASS=0 ;;
    *) [ "$CODE" = "403" ] || PASS=0 ;;
  esac

  CODE=$($CURL -sS -o "$OUT/query-$USER.json" -w '%{http_code}'     -H "Authorization: Bearer $TOKEN"     -H 'Content-Type: application/json'     --data-binary '{"action":"login","limit":10}'     "http://127.0.0.1:$PORT/api/v1/audit/query")
  echo "$USER-audit_query_http=$CODE" >>"$SUMMARY"

  case "$USER" in
    s3_security|s3_auditor|s3_platform) [ "$CODE" = "200" ] || PASS=0 ;;
    *) [ "$CODE" = "403" ] || PASS=0 ;;
  esac

  CODE=$($CURL -sS -o "$OUT/logout-$USER.json" -w '%{http_code}'     -X POST -H "Authorization: Bearer $TOKEN"     "http://127.0.0.1:$PORT/api/v1/auth/logout")
  echo "$USER-logout_http=$CODE" >>"$SUMMARY"
  [ "$CODE" = "200" ] || PASS=0
  TOKEN=''
done

if [ -f "$AUDIT" ]; then
  /usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -e '
    my $a=INPSan::Security::Audit->new(path=>$ARGV[0],product_version=>"0.2.4-dev");
    my $v=$a->verify_chain();
    die unless $v->{ok};
    my $h=$a->health();
    print "audit_chain_verify=PASS records=$v->{records}\n";
    print "audit_health_state=$h->{state}\n";
    print "audit_archive_count=$h->{archive_count}\n";
  ' "$AUDIT" >"$OUT/audit-final-verify.txt" 2>&1 || PASS=0

  if grep -F "$TESTPASS" "$AUDIT" >/dev/null 2>&1; then
    echo "audit_password_leak=FAIL" >>"$SUMMARY"
    PASS=0
  else
    echo "audit_password_leak=PASS" >>"$SUMMARY"
  fi
else
  echo "audit_present=FAIL" >>"$SUMMARY"
  PASS=0
fi

LISTEN=$(/usr/bin/netstat -an 2>/dev/null | grep "$PORT" || true)
echo "$LISTEN" >"$OUT/listen.txt"
if echo "$LISTEN" | grep -v "127.0.0.1" | grep "$PORT" >/dev/null 2>&1; then
  echo "loopback_only=FAIL" >>"$SUMMARY"; PASS=0
else
  echo "loopback_only=PASS" >>"$SUMMARY"
fi

unset INPSAN_TESTPASS TESTPASS
rm -f "$OUT"/login-*.json 2>/dev/null || true

(
  cd "$OUT" || exit 1
  /usr/bin/digest -a sha256 * 2>/dev/null || /usr/bin/sha256sum * 2>/dev/null || true
) >"$OUT/SHA256SUMS.txt"

if [ "$PASS" -eq 1 ]; then
  echo "validation=PASS" >>"$SUMMARY"
  echo "INPSan S3 Audit live validation: PASS"
else
  echo "validation=FAIL" >>"$SUMMARY"
  echo "INPSan S3 Audit live validation: FAIL"
fi

echo "Evidence directory: $OUT"
echo "Return: summary.txt static-audit-s3.txt benchmark-audit.txt audit-final-verify.txt server.log SHA256SUMS.txt"
[ "$PASS" -eq 1 ]
