#!/usr/bin/bash
# INPSan S4 TLS/session preflight — read-only
set -u

PASS=1

echo "preflight=INPSan-S4-v0.2.5"
echo "hostname=$(hostname)"
echo "uname=$(uname -a)"

echo "== openssl =="
if [ -x /usr/bin/openssl ]; then
  /usr/bin/openssl version
else
  echo "openssl=FAIL"
  PASS=0
fi

echo "== IO::Socket::SSL =="
if /usr/bin/perl -MIO::Socket::SSL -e 'print "IO::Socket::SSL=$IO::Socket::SSL::VERSION\n"' 2>/dev/null; then
  :
else
  echo "IO::Socket::SSL=FAIL"
  PASS=0
fi

echo "== core Perl modules =="
/usr/bin/perl -MJSON::PP -MDigest::SHA -MTime::HiRes -MIO::Socket::INET -e 'print "core_perl_modules=PASS\n"' || PASS=0

echo "== curl =="
if command -v curl >/dev/null 2>&1; then
  curl --version | sed -n '1p'
else
  echo "curl=FAIL"
  PASS=0
fi

if [ "$PASS" -eq 1 ]; then
  echo "preflight_result=PASS"
else
  echo "preflight_result=FAIL"
fi

[ "$PASS" -eq 1 ]
