#!/usr/bin/bash
# INPSan S4 live validation — TLS / Session / Certificate
# Non-destructive, loopback-only evaluation.
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"
CP="$BASE/inpsan-control-plane-v0.2.5-dev.pl"
PREFLIGHT="$BASE/preflight-s4-v0.2.5.sh"
VERIFY="$BASE/verify-s4-v0.2.5.sh"
BOOTSTRAP="$BASE/bootstrap-tls-v0.2.5.sh"
BENCH="$BASE/benchmark-s4-v0.2.5.sh"

PORT=18443
STAMP=$(date '+%Y%m%d-%H%M%S')
OUT="/var/tmp/inpsan-s4-live-$STAMP"
STORE="$OUT/users.json"
AUDIT="$OUT/security-audit.jsonl"
SERVERLOG="$OUT/server.log"
SUMMARY="$OUT/summary.txt"
TLSDIR="$OUT/tls"

mkdir -p "$OUT"
chmod 700 "$OUT"

CURL=$(command -v curl 2>/dev/null || true)
[ -n "$CURL" ] || { echo "curl_required=FAIL" | tee "$SUMMARY"; exit 2; }

PASS=1
PID=''

cleanup() {
  if [ -n "$PID" ]; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "test_suite=INPSan-S4-TLS-SESSION-LIVE" >"$SUMMARY"
echo "captured_at=$(date '+%Y-%m-%dT%H:%M:%S%z')" >>"$SUMMARY"
echo "hostname=$(hostname)" >>"$SUMMARY"
echo "uname=$(uname -a)" >>"$SUMMARY"
echo "control_plane=v0.2.5-dev" >>"$SUMMARY"
echo "port=$PORT" >>"$SUMMARY"

bash "$PREFLIGHT" >"$OUT/preflight.txt" 2>&1 || PASS=0
bash "$VERIFY" >"$OUT/static-s4.txt" 2>&1 || PASS=0
bash "$BOOTSTRAP" "$TLSDIR" >"$OUT/tls-bootstrap.txt" 2>&1 || PASS=0

CA="$TLSDIR/inpsan-eval-ca.cert.pem"
CERT="$TLSDIR/inpsan-eval-server.cert.pem"
KEY="$TLSDIR/inpsan-eval-server.key.pem"

[ -f "$CA" ] && [ -f "$CERT" ] && [ -f "$KEY" ] || {
  echo "tls_material=FAIL" >>"$SUMMARY"
  exit 3
}

KEYMODE=$(/usr/bin/perl -e '@s=stat($ARGV[0]); printf "%04o", $s[2]&07777' "$KEY")
echo "tls_key_mode=$KEYMODE" >>"$SUMMARY"
[ "$KEYMODE" = "0600" ] || PASS=0

/usr/bin/perl -I"$LIB" -MINPSan::Security::Certificate -MJSON::PP -e '
  my $c=INPSan::Security::Certificate->new(cert_path=>$ARGV[0],key_path=>$ARGV[1]);
  my $h=$c->health();
  die unless $h->{ok};
  die unless $h->{key_mode_ok};
  die unless $h->{expires_more_than_30d};
  print JSON::PP->new->canonical(1)->pretty(1)->encode($h);
' "$CERT" "$KEY" >"$OUT/certificate-health.json" 2>&1 || PASS=0

TESTPASS=$(/usr/bin/perl -MDigest::SHA=sha256_hex -e 'print substr(sha256_hex(rand().$$.time()),0,24),"Aa!7"')
export INPSAN_TESTPASS="$TESTPASS" INPSAN_TESTSTORE="$STORE"

/usr/bin/perl -I"$LIB" -MINPSan::Security::Auth -e '
  my $a=INPSan::Security::Auth->new(user_store=>$ENV{INPSAN_TESTSTORE});
  my $p=$ENV{INPSAN_TESTPASS};
  $a->create_user(username=>"s4_viewer",password=>$p,roles=>["viewer"],scopes=>["node:local"]);
  $a->create_user(username=>"s4_security",password=>$p,roles=>["security-admin"],scopes=>["node:local"]);
  $a->create_user(username=>"s4_auditor",password=>$p,roles=>["auditor"],scopes=>["node:local"]);
  $a->create_user(username=>"s4_platform",password=>$p,roles=>["platform-admin"],scopes=>["node:local"]);
  print "user_provisioning=PASS\n";
' >"$OUT/user-provisioning.txt" 2>&1 || PASS=0

INPSAN_CP_USER_STORE="$STORE" INPSAN_CP_AUTH_AUDIT="$AUDIT" INPSAN_CP_TLS_CERT="$CERT" INPSAN_CP_TLS_KEY="$KEY"   /usr/bin/perl -I"$LIB" "$CP"   --port "$PORT"   --user-store "$STORE"   --audit-log "$AUDIT"   --tls-cert "$CERT"   --tls-key "$KEY"   --idle-timeout 2   --absolute-timeout 8   >"$SERVERLOG" 2>&1 &
PID=$!
sleep 1

if ! kill -0 "$PID" 2>/dev/null; then
  echo "control_plane_start=FAIL" >>"$SUMMARY"
  exit 4
fi
echo "control_plane_start=PASS" >>"$SUMMARY"

BASEURL="https://127.0.0.1:$PORT"

echo "== plaintext rejection =="
PLAIN=$($CURL -sS --max-time 2 -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/api/v1/product/version" 2>/dev/null || true)
echo "plaintext_http_code=${PLAIN:-000}" >>"$SUMMARY"
[ "${PLAIN:-000}" != "200" ] || PASS=0

echo "== TLS 1.2 acceptance =="
if echo | /usr/bin/openssl s_client -connect "127.0.0.1:$PORT" -tls1_2 -CAfile "$CA" -verify_return_error >"$OUT/tls12.txt" 2>&1; then
  echo "tls12=PASS" >>"$SUMMARY"
else
  echo "tls12=FAIL" >>"$SUMMARY"
  PASS=0
fi

echo "== TLS 1.1 rejection =="
if echo | /usr/bin/openssl s_client -connect "127.0.0.1:$PORT" -tls1_1 -CAfile "$CA" >"$OUT/tls11.txt" 2>&1; then
  echo "tls11_rejected=FAIL" >>"$SUMMARY"
  PASS=0
else
  if grep -qi "unknown option" "$OUT/tls11.txt"; then
    echo "tls11_probe=CLIENT_UNSUPPORTED" >>"$SUMMARY"
  else
    echo "tls11_rejected=PASS" >>"$SUMMARY"
  fi
fi

echo "== invalid/fake session rejection =="
FAKE=$($CURL -sS --cacert "$CA"   -H 'Cookie: __Host-INPSAN_SESSION=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'   -o "$OUT/fake-session.json" -w '%{http_code}'   "$BASEURL/api/v1/auth/me")
echo "fake_session_http=$FAKE" >>"$SUMMARY"
[ "$FAKE" = "401" ] || PASS=0

login_user() {
  user="$1"; cookie="$2"; headers="$3"; body="$4"
  $CURL -sS --cacert "$CA"     -c "$cookie"     -D "$headers"     -o "$body"     -w '%{http_code}'     -H 'Content-Type: application/json'     --data-binary "{\"username\":\"$user\",\"password\":\"$TESTPASS\"}"     "$BASEURL/api/v1/auth/login"
}

for USER in s4_viewer s4_security s4_auditor s4_platform; do
  COOKIE="$OUT/cookie-$USER.txt"
  HEADERS="$OUT/headers-$USER.txt"
  BODY="$OUT/login-$USER.json"

  CODE=$(login_user "$USER" "$COOKIE" "$HEADERS" "$BODY")
  echo "$USER-login_http=$CODE" >>"$SUMMARY"
  [ "$CODE" = "200" ] || { PASS=0; continue; }

  if grep -q '"access_token"' "$BODY"; then
    echo "$USER-token_in_body=FAIL" >>"$SUMMARY"
    PASS=0
  else
    echo "$USER-token_in_body=PASS" >>"$SUMMARY"
  fi

  grep -qi '^Strict-Transport-Security:' "$HEADERS" || PASS=0
  grep -qi '^Content-Security-Policy:' "$HEADERS" || PASS=0
  grep -qi '^Permissions-Policy:' "$HEADERS" || PASS=0
  grep -qi '^Set-Cookie: __Host-INPSAN_SESSION=' "$HEADERS" || PASS=0
  grep -qi 'Secure' "$HEADERS" || PASS=0
  grep -qi 'HttpOnly' "$HEADERS" || PASS=0
  grep -qi 'SameSite=Strict' "$HEADERS" || PASS=0

  CODE=$($CURL -sS --cacert "$CA" -b "$COOKIE"     -o "$OUT/me-$USER.json" -w '%{http_code}'     "$BASEURL/api/v1/auth/me")
  echo "$USER-me_http=$CODE" >>"$SUMMARY"
  [ "$CODE" = "200" ] || PASS=0

  CODE=$($CURL -sS --cacert "$CA" -b "$COOKIE"     -o "$OUT/tls-health-$USER.json" -w '%{http_code}'     "$BASEURL/api/v1/security/tls")
  echo "$USER-tls_health_http=$CODE" >>"$SUMMARY"

  case "$USER" in
    s4_viewer) [ "$CODE" = "403" ] || PASS=0 ;;
    s4_security|s4_auditor|s4_platform) [ "$CODE" = "200" ] || PASS=0 ;;
  esac

  if [ "$USER" = "s4_security" ]; then
    bash "$BENCH" "$BASEURL" "$CA" "$COOKIE" 100 >"$OUT/benchmark-s4.txt" 2>&1 || PASS=0
  fi

  CODE=$($CURL -sS --cacert "$CA" -b "$COOKIE" -c "$COOKIE"     -X POST -o "$OUT/logout-$USER.json" -w '%{http_code}'     "$BASEURL/api/v1/auth/logout")
  echo "$USER-logout_http=$CODE" >>"$SUMMARY"
  [ "$CODE" = "200" ] || PASS=0

  CODE=$($CURL -sS --cacert "$CA" -b "$COOKIE"     -o "$OUT/replay-$USER.json" -w '%{http_code}'     "$BASEURL/api/v1/auth/me")
  echo "$USER-replay_http=$CODE" >>"$SUMMARY"
  [ "$CODE" = "401" ] || PASS=0

  rm -f "$COOKIE" "$HEADERS"
done

echo "== live idle timeout =="
COOKIE="$OUT/cookie-idle.txt"
HEADERS="$OUT/headers-idle.txt"
BODY="$OUT/login-idle.json"
CODE=$(login_user "s4_viewer" "$COOKIE" "$HEADERS" "$BODY")
[ "$CODE" = "200" ] || PASS=0
sleep 3
CODE=$($CURL -sS --cacert "$CA" -b "$COOKIE"   -o "$OUT/idle-expiry.json" -w '%{http_code}'   "$BASEURL/api/v1/auth/me")
echo "idle_expiry_http=$CODE" >>"$SUMMARY"
[ "$CODE" = "401" ] || PASS=0
rm -f "$COOKIE" "$HEADERS"

if [ -f "$AUDIT" ]; then
  if grep -F "$TESTPASS" "$AUDIT" >/dev/null 2>&1; then
    echo "audit_password_leak=FAIL" >>"$SUMMARY"
    PASS=0
  else
    echo "audit_password_leak=PASS" >>"$SUMMARY"
  fi

  if grep -F "__Host-INPSAN_SESSION" "$AUDIT" >/dev/null 2>&1; then
    echo "audit_cookie_leak=FAIL" >>"$SUMMARY"
    PASS=0
  else
    echo "audit_cookie_leak=PASS" >>"$SUMMARY"
  fi
fi

LISTEN=$(/usr/bin/netstat -an 2>/dev/null | grep "$PORT" || true)
echo "$LISTEN" >"$OUT/listen.txt"
if echo "$LISTEN" | grep -v "127.0.0.1" | grep "$PORT" >/dev/null 2>&1; then
  echo "loopback_only=FAIL" >>"$SUMMARY"
  PASS=0
else
  echo "loopback_only=PASS" >>"$SUMMARY"
fi

unset INPSAN_TESTPASS TESTPASS
rm -f "$OUT"/cookie-*.txt "$OUT"/headers-*.txt 2>/dev/null || true
rm -f "$TLSDIR"/*.key.pem "$TLSDIR"/*.cnf 2>/dev/null || true

: >"$OUT/SHA256SUMS.txt"
for F in "$OUT"/*; do
  [ -f "$F" ] || continue
  [ "$(basename "$F")" = "SHA256SUMS.txt" ] && continue
  HASH=$(/usr/bin/digest -a sha256 "$F" 2>/dev/null || true)
  [ -n "$HASH" ] && echo "($(basename "$F")) = $HASH" >>"$OUT/SHA256SUMS.txt"
done

if [ "$PASS" -eq 1 ]; then
  echo "validation=PASS" >>"$SUMMARY"
  echo "INPSan S4 TLS/session live validation: PASS"
else
  echo "validation=FAIL" >>"$SUMMARY"
  echo "INPSan S4 TLS/session live validation: FAIL"
fi

echo "Evidence directory: $OUT"
echo "Return: summary.txt preflight.txt static-s4.txt tls-bootstrap.txt certificate-health.json benchmark-s4.txt server.log SHA256SUMS.txt"
[ "$PASS" -eq 1 ]
