#!/usr/bin/bash
# INPSan Control Plane v0.1.0-dev verification
set -u
BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PL="$BASE/inpsan-control-plane-v0.1.0-dev.pl"

echo '== syntax ==' 
/usr/bin/perl -c "$PL" || exit 1

echo '== dependencies ==' 
/usr/bin/perl -MJSON::PP -MIO::Socket::INET -MGetopt::Long -e 'print "dependencies=PASS\n"' || exit 1

echo '== safety contract ==' 
grep -q "LocalAddr => '127.0.0.1'" "$PL" || exit 1
! grep -Eq "\b(POST|PUT|PATCH|DELETE)\b" "$PL" || { echo 'state-changing method marker found'; exit 1; }

echo 'INPSan Control Plane v0.1.0-dev static verification: PASS'
echo 'Live endpoint verification on OmniOS is still required.'