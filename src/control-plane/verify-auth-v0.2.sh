#!/usr/bin/bash
# INPSan Control Plane v0.2.0-dev — SEC-IMP-01 static/security verification
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PL="$BASE/inpsan-control-plane-v0.2.0-dev.pl"
AUTH="$BASE/lib/INPSan/Security/Auth.pm"

echo '== syntax =='
/usr/bin/perl -I"$BASE/lib" -c "$AUTH" || exit 1
/usr/bin/perl -I"$BASE/lib" -c "$PL" || exit 1

echo '== core dependencies =='
/usr/bin/perl -MDigest::SHA -MJSON::PP -MMIME::Base64 -MIO::Socket::INET -MGetopt::Long -e 'print "core_dependencies=PASS\n"' || exit 1

echo '== loopback-only development safety =='
grep -q "LocalAddr => '127.0.0.1'" "$PL" || exit 1

echo '== independent auth dependency =='
grep -q "use INPSan::Security::Auth" "$PL" || exit 1

echo '== bearer authorization gate =='
grep -q "require_session" "$PL" || exit 1
grep -q "WWW-Authenticate" "$PL" || exit 1

echo '== password verifier safety =='
grep -q "pbkdf2-sha256" "$AUTH" || exit 1
grep -q "/dev/urandom" "$AUTH" || exit 1
grep -q "constant_time_eq" "$AUTH" || exit 1

echo '== no storage write surface =='
! grep -Eq "['\"]/(?:api/v1/)?(?:storage|system)/[^'\"]*(?:create|delete|destroy|update|write|map|unmap)" "$PL" || exit 1

echo 'INPSan SEC-IMP-01 static verification: PASS'
echo 'Live OmniOS authentication/session verification remains required before SEC-IMP-01 can be marked PASS.'
