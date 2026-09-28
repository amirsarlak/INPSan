#!/usr/bin/bash
# INPSan SEC-IMP-02 static RBAC verification
set -u
BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RBAC="$BASE/lib/INPSan/Security/RBAC.pm"
CP="$BASE/inpsan-control-plane-v0.2.1-dev.pl"

echo '== syntax =='
/usr/bin/perl -I"$BASE/lib" -c "$RBAC" || exit 1
/usr/bin/perl -I"$BASE/lib" -c "$CP" || exit 1

echo '== deny-by-default =='
/usr/bin/perl -I"$BASE/lib" -MINPSan::Security::RBAC -e '
  my $r=INPSan::Security::RBAC->new();
  die unless !$r->has_capability(["viewer"],"storage.manage");
  die unless $r->has_capability(["viewer"],"storage.read");
  die unless $r->has_capability(["platform-admin"],"roles.manage");
  my $d=$r->authorize(roles=>["viewer"],required_capability=>"storage.manage");
  die if $d->{allowed};
  print "rbac_semantics=PASS\n";
' || exit 1

echo '== endpoint permission wiring =='
grep -q "authorize_request(\$session, 'system.read')" "$CP" || exit 1
grep -q "authorize_request(\$session, 'health.read')" "$CP" || exit 1
grep -q "authorize_request(\$session, 'storage.read')" "$CP" || exit 1
grep -q "403 => 'Forbidden'" "$CP" || exit 1

echo 'INPSan SEC-IMP-02 static RBAC verification: PASS'
echo 'Live negative authorization testing is still required before PASS.'
