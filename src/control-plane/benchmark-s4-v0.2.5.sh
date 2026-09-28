#!/usr/bin/bash
# INPSan S4 HTTPS/session micro-benchmark
set -u

URL="$1"
CERT="$2"
COOKIE="$3"
COUNT="${4:-100}"
CURL=$(command -v curl 2>/dev/null || true)
[ -n "$CURL" ] || exit 2

echo "benchmark=tls-session-read"
echo "count=$COUNT"
echo "host=$(hostname)"
echo "uname=$(uname -a)"

START=$(/usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time()')
I=1
while [ "$I" -le "$COUNT" ]; do
  CODE=$($CURL -sS --cacert "$CERT" -b "$COOKIE" -o /dev/null -w '%{http_code}' "$URL/api/v1/auth/me") || exit 1
  [ "$CODE" = "200" ] || exit 1
  I=$((I + 1))
done
END=$(/usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time()')

TOTAL=$(/usr/bin/perl -e 'my($s,$e)=@ARGV; printf "%.3f",$e-$s' "$START" "$END")
AVG=$(/usr/bin/perl -e 'my($s,$e,$n)=@ARGV; printf "%.3f",(($e-$s)*1000)/$n' "$START" "$END" "$COUNT")

echo "https_total_seconds=$TOTAL"
echo "https_avg_ms_per_request=$AVG"
echo "verified_requests=$COUNT"
