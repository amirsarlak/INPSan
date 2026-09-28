#!/usr/bin/bash
# INPSan Control Plane v0.2.2-dev static security verification
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"
CP="$BASE/inpsan-control-plane-v0.2.2-dev.pl"
AUTH="$LIB/INPSan/Security/Auth.pm"
RBAC="$LIB/INPSan/Security/RBAC.pm"
POLICY="$LIB/INPSan/Security/EndpointPolicy.pm"
AUDIT="$LIB/INPSan/Security/Audit.pm"
SCOPE="$LIB/INPSan/Security/Scope.pm"

echo '== syntax =='
/usr/bin/perl -I"$LIB" -c "$AUTH" || exit 1
/usr/bin/perl -I"$LIB" -c "$RBAC" || exit 1
/usr/bin/perl -I"$LIB" -c "$POLICY" || exit 1
/usr/bin/perl -I"$LIB" -c "$AUDIT" || exit 1
/usr/bin/perl -I"$LIB" -c "$SCOPE" || exit 1
/usr/bin/perl -I"$LIB" -c "$CP" || exit 1

echo '== RBAC semantics =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::RBAC -e '
  my $r=INPSan::Security::RBAC->new();
  die unless $r->has_capability(["viewer"],"storage.read");
  die if $r->has_capability(["viewer"],"storage.manage");
  die unless $r->has_capability(["platform-admin"],"roles.manage");
  my $d=$r->authorize(roles=>["viewer"], required_capability=>"storage.manage");
  die if $d->{allowed};
  print "rbac=PASS\n";
' || exit 1

echo '== Endpoint policy semantics =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::EndpointPolicy -e '
  my $p=INPSan::Security::EndpointPolicy->new();
  my $a=$p->lookup("GET","/api/v1/storage/pools");
  die unless $a && $a->{permission} eq "storage.read";
  die if $p->lookup("DELETE","/api/v1/storage/pools");
  print "endpoint_policy=PASS\n";
' || exit 1


echo '== Scope semantics =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::Scope -e '
  my $s=INPSan::Security::Scope->new();
  die unless $s->valid_scope("node:local");
  die if $s->valid_scope("../etc/passwd");
  my $a=$s->allows(grants=>["pool:Pool-1800GB"], required_scope=>"pool:Pool-1800GB");
  die unless $a->{allowed};
  my $d=$s->allows(grants=>["pool:Pool-300G"], required_scope=>"pool:Pool-1800GB");
  die if $d->{allowed};
  print "scope=PASS\n";
' || exit 1

echo '== Canonical audit schema safety =='
TMP="/var/tmp/inpsan-audit-static-$$.jsonl"
/usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -e '
  my $p=$ARGV[0];
  my $a=INPSan::Security::Audit->new(path=>$p,product_version=>"test");
  $a->write_event(actor_id=>"tester",actor_type=>"user",action=>"authorization",target_type=>"endpoint",target_id=>"/x",permission=>"storage.read",outcome=>"deny",reason=>"test");
' "$TMP" || exit 1
/usr/bin/perl -MJSON::PP -0777 -e '
  my $s=<STDIN>; my ($line)=split /\n/,$s;
  my $j=decode_json($line);
  die unless $j->{schema_version} eq "1.0";
  die unless $j->{actor_id} eq "tester";
  die unless $j->{permission} eq "storage.read";
  die unless $j->{outcome} eq "deny";
  print "audit_schema=PASS\n";
' <"$TMP" || exit 1
rm -f "$TMP"

echo '== Audit hash-chain integrity =='
CHAIN="/var/tmp/inpsan-audit-chain-$.jsonl"
/usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -e '
  my $p=$ARGV[0];
  my $a=INPSan::Security::Audit->new(path=>$p,product_version=>"test");
  $a->write_event(actor_id=>"alice",actor_type=>"user",action=>"login",target_type=>"session",outcome=>"success");
  $a->write_event(actor_id=>"alice",actor_type=>"user",action=>"authorization",target_type=>"pool",target_id=>"Pool-1800GB",permission=>"storage.read",outcome=>"success");
  my $v=$a->verify_chain();
  die "chain verify failed\n" unless $v->{ok} && $v->{records} == 2;
  print "audit_chain=PASS\n";
' "$CHAIN" || exit 1

/usr/bin/perl -0777 -pi -e 's/"outcome":"success"/"outcome":"tampered"/ if $. == 1' "$CHAIN"
/usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -e '
  my $a=INPSan::Security::Audit->new(path=>$ARGV[0],product_version=>"test");
  my $v=$a->verify_chain();
  die "tamper was not detected\n" if $v->{ok};
  print "audit_tamper_detection=PASS reason=$v->{reason}\n";
' "$CHAIN" || exit 1
rm -f "$CHAIN" "$CHAIN.state"

echo '== Wiring =='
grep -q "use INPSan::Security::EndpointPolicy" "$CP" || exit 1
grep -q "use INPSan::Security::Audit" "$CP" || exit 1
grep -q "use INPSan::Security::Scope" "$CP" || exit 1
grep -q "authorize_endpoint" "$CP" || exit 1
grep -q "endpoint_policy_missing" "$CP" || exit 1
grep -q "storage_pool_detail" "$CP" || exit 1

echo 'INPSan Control Plane v0.2.2-dev static security verification: PASS'
echo 'Live OmniOS AuthN/RBAC/Audit validation is still required before S1/S2/S3 PASS.'
