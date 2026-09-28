#!/usr/bin/bash
set -u
BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"
CP="$BASE/inpsan-control-plane-v0.2.2-dev.pl"
STATIC="$BASE/verify-security-v0.2.2.sh"
ROLE_SCOPE="$BASE/verify-role-scope-matrix-v0.2.2.sh"
PORT=18082
STAMP=$(date '+%Y%m%d-%H%M%S')
OUT="/var/tmp/inpsan-sec-live-$STAMP"
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
echo "test_suite=INPSan-SEC-LIVE-3.3" >"$SUMMARY"
echo "captured_at=$(date '+%Y-%m-%dT%H:%M:%S%z')" >>"$SUMMARY"
echo "hostname=$(hostname)" >>"$SUMMARY"
echo "uname=$(uname -a)" >>"$SUMMARY"
echo "control_plane=v0.2.2-dev" >>"$SUMMARY"
echo "port=$PORT" >>"$SUMMARY"
bash "$STATIC" >"$OUT/static-security.txt" 2>&1 || PASS=0
bash "$ROLE_SCOPE" >"$OUT/static-role-scope.txt" 2>&1 || PASS=0
POOL1=$(/usr/sbin/zpool list -H -o name 2>/dev/null | sed -n '1p')
POOL2=$(/usr/sbin/zpool list -H -o name 2>/dev/null | sed -n '2p')
if [ -z "$POOL1" ]; then echo "pool_discovery=FAIL" >>"$SUMMARY"; exit 3; fi
echo "pool1=$POOL1" >>"$SUMMARY"
[ -n "$POOL2" ] && echo "pool2=$POOL2" >>"$SUMMARY"
TESTPASS=$(/usr/bin/perl -MDigest::SHA=sha256_hex -e 'print substr(sha256_hex(rand().$$.time()),0,24),"Aa!7"')
export INPSAN_TESTPASS="$TESTPASS" INPSAN_TESTPOOL1="$POOL1" INPSAN_TESTSTORE="$STORE"
/usr/bin/perl -I"$LIB" -MINPSan::Security::Auth -e '
  my $a=INPSan::Security::Auth->new(user_store=>$ENV{INPSAN_TESTSTORE});
  my $p=$ENV{INPSAN_TESTPASS}; my $pool=$ENV{INPSAN_TESTPOOL1};
  $a->create_user(username=>"sec_viewer",password=>$p,roles=>["viewer"],scopes=>["pool:$pool"]);
  $a->create_user(username=>"sec_storage",password=>$p,roles=>["storage-admin"],scopes=>["pool:$pool"]);
  $a->create_user(username=>"sec_security",password=>$p,roles=>["security-admin"],scopes=>["node:local"]);
  $a->create_user(username=>"sec_auditor",password=>$p,roles=>["auditor"],scopes=>["pool:$pool"]);
  $a->create_user(username=>"sec_platform",password=>$p,roles=>["platform-admin"],scopes=>["pool:$pool"]);
  print "user_provisioning=PASS\n";
' >"$OUT/user-provisioning.txt" 2>&1 || PASS=0
if [ -f "$STORE" ]; then
  MODE=$(/usr/bin/perl -e '@s=stat($ARGV[0]); printf "%04o", $s[2]&07777' "$STORE")
  echo "user_store_mode=$MODE" >>"$SUMMARY"; [ "$MODE" = "0600" ] || PASS=0
else echo "user_store_mode=MISSING" >>"$SUMMARY"; PASS=0; fi
INPSAN_CP_USER_STORE="$STORE" INPSAN_CP_AUTH_AUDIT="$AUDIT" /usr/bin/perl -I"$LIB" "$CP" --port "$PORT" --user-store "$STORE" --audit-log "$AUDIT" >"$SERVERLOG" 2>&1 &
PID=$!
sleep 1
if ! kill -0 "$PID" 2>/dev/null; then echo "control_plane_start=FAIL" >>"$SUMMARY"; exit 4; fi
echo "control_plane_start=PASS" >>"$SUMMARY"
json_login() {
  user="$1"; outfile="$2"
  $CURL -sS -o "$outfile" -w '%{http_code}' -H 'Content-Type: application/json' --data-binary "{\"username\":\"$user\",\"password\":\"$TESTPASS\"}" "http://127.0.0.1:$PORT/api/v1/auth/login"
}
extract_token() {
  /usr/bin/perl -MJSON::PP -0777 -e 'my $j=decode_json(<STDIN>); die unless $j->{ok} && $j->{data}{access_token}; print $j->{data}{access_token};' <"$1" 2>/dev/null
}
CODE=$($CURL -sS -o "$OUT/anonymous.json" -w '%{http_code}' "http://127.0.0.1:$PORT/api/v1/storage/pools")
echo "anonymous_storage_http=$CODE" >>"$SUMMARY"; [ "$CODE" = "401" ] || PASS=0
CODE=$($CURL -sS -o "$OUT/invalid-login.json" -w '%{http_code}' -H 'Content-Type: application/json' --data-binary '{"username":"sec_viewer","password":"wrong-password"}' "http://127.0.0.1:$PORT/api/v1/auth/login")
echo "invalid_login_http=$CODE" >>"$SUMMARY"; [ "$CODE" = "401" ] || PASS=0
for USER in sec_viewer sec_storage sec_security sec_auditor sec_platform; do
  RESP="$OUT/login-$USER.json"
  CODE=$(json_login "$USER" "$RESP")
  echo "$USER-login_http=$CODE" >>"$SUMMARY"
  [ "$CODE" = "200" ] || { PASS=0; continue; }
  TOKEN=$(extract_token "$RESP")
  [ -n "$TOKEN" ] || { PASS=0; continue; }
  rm -f "$RESP"
  CODE=$($CURL -sS -o "$OUT/me-$USER.json" -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:$PORT/api/v1/auth/me")
  echo "$USER-me_http=$CODE" >>"$SUMMARY"; [ "$CODE" = "200" ] || PASS=0
  CODE=$($CURL -sS -o "$OUT/pools-$USER.json" -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:$PORT/api/v1/storage/pools")
  echo "$USER-pool_list_http=$CODE" >>"$SUMMARY"
  case "$USER" in sec_security) [ "$CODE" = "403" ] || PASS=0 ;; *) [ "$CODE" = "200" ] || PASS=0 ;; esac
  CODE=$($CURL -sS -o "$OUT/pooldetail-$USER.json" -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:$PORT/api/v1/storage/pools/$POOL1")
  echo "$USER-pool1_detail_http=$CODE" >>"$SUMMARY"
  case "$USER" in sec_security) [ "$CODE" = "403" ] || PASS=0 ;; *) [ "$CODE" = "200" ] || PASS=0 ;; esac
  if [ -n "$POOL2" ]; then
    CODE=$($CURL -sS -o "$OUT/pool2-$USER.json" -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:$PORT/api/v1/storage/pools/$POOL2")
    echo "$USER-pool2_detail_http=$CODE" >>"$SUMMARY"; [ "$CODE" = "403" ] || PASS=0
  fi
  CODE=$($CURL -sS -o "$OUT/logout-$USER.json" -w '%{http_code}' -X POST -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:$PORT/api/v1/auth/logout")
  echo "$USER-logout_http=$CODE" >>"$SUMMARY"; [ "$CODE" = "200" ] || PASS=0
  CODE=$($CURL -sS -o "$OUT/replay-$USER.json" -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:$PORT/api/v1/auth/me")
  echo "$USER-replay_http=$CODE" >>"$SUMMARY"; [ "$CODE" = "401" ] || PASS=0
  TOKEN=''
done
if [ -f "$AUDIT" ]; then
  AUDIT_MODE=$(/usr/bin/perl -e '@s=stat($ARGV[0]); printf "%04o", $s[2]&07777' "$AUDIT")
  echo "audit_mode=$AUDIT_MODE" >>"$SUMMARY"; [ "$AUDIT_MODE" = "0600" ] || PASS=0
  if grep -F "$TESTPASS" "$AUDIT" >/dev/null 2>&1; then echo "audit_password_leak=FAIL" >>"$SUMMARY"; PASS=0; else echo "audit_password_leak=PASS" >>"$SUMMARY"; fi
  /usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -e 'my $a=INPSan::Security::Audit->new(path=>$ARGV[0],product_version=>"0.2.2-dev"); my $v=$a->verify_chain(); die unless $v->{ok}; print "audit_chain_verify=PASS records=$v->{records}\n";' "$AUDIT" >"$OUT/audit-verify.txt" 2>&1 || PASS=0
else echo "audit_present=FAIL" >>"$SUMMARY"; PASS=0; fi
LISTEN=$(/usr/bin/netstat -an 2>/dev/null | grep "$PORT" || true)
echo "$LISTEN" >"$OUT/listen.txt"
if echo "$LISTEN" | grep -v "127.0.0.1" | grep "$PORT" >/dev/null 2>&1; then echo "loopback_only=FAIL" >>"$SUMMARY"; PASS=0; else echo "loopback_only=PASS" >>"$SUMMARY"; fi
unset INPSAN_TESTPASS TESTPASS
rm -f "$OUT"/login-*.json 2>/dev/null || true
(
  cd "$OUT" || exit 1
  /usr/bin/digest -a sha256 * 2>/dev/null || /usr/bin/sha256sum * 2>/dev/null || true
) >"$OUT/SHA256SUMS.txt"
if [ "$PASS" -eq 1 ]; then echo "validation=PASS" >>"$SUMMARY"; echo "INPSan live security validation: PASS"; else echo "validation=FAIL" >>"$SUMMARY"; echo "INPSan live security validation: FAIL"; fi
echo "Evidence directory: $OUT"
echo "Return: summary.txt static-security.txt static-role-scope.txt user-provisioning.txt audit-verify.txt security-audit.jsonl server.log SHA256SUMS.txt"
[ "$PASS" -eq 1 ]
