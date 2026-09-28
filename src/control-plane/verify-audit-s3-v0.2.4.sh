#!/usr/bin/bash
# INPSan S3 Audit Plane static/integration verification — v0.2.4-dev
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"
CP="$BASE/inpsan-control-plane-v0.2.4-dev.pl"
AUDIT="$LIB/INPSan/Security/Audit.pm"
POLICY="$LIB/INPSan/Security/EndpointPolicy.pm"

echo '== syntax =='
/usr/bin/perl -I"$LIB" -c "$AUDIT" || exit 1
/usr/bin/perl -I"$LIB" -c "$POLICY" || exit 1
/usr/bin/perl -I"$LIB" -c "$CP" || exit 1

echo '== audit rotation / retention / health / query / reconciliation =='
TMP="/var/tmp/inpsan-audit-s3-$$.jsonl"
/usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -e '
  my $p=$ARGV[0];
  my $a=INPSan::Security::Audit->new(
    path=>$p,
    product_version=>"test",
    max_file_bytes=>700,
    max_archives=>2,
    warning_ratio=>0.50,
    critical_ratio=>0.90
  );

  for my $i (1..40) {
    $a->write_event(
      actor_id=>($i % 2 ? "alice" : "bob"),
      actor_type=>"user",
      action=>($i % 3 ? "authorization" : "login"),
      target_type=>"pool",
      target_id=>"Pool-1800GB",
      permission=>"storage.read",
      outcome=>($i % 5 ? "success" : "deny"),
      reason=>"test",
      event_class=>"security_critical"
    );
  }

  my $v=$a->verify_chain();
  die "verify failed\n" unless $v->{ok};
  die "no records\n" unless $v->{records} > 0;

  my $h=$a->health();
  die "health missing\n" unless $h->{state};
  die "retention failed\n" if $h->{archive_count} > 2;

  my $q=$a->query_events(actor_id=>"alice",limit=>5);
  die "query limit failed\n" unless @$q <= 5;
  for my $e (@$q) { die "query filter failed\n" unless $e->{actor_id} eq "alice"; }

  unlink($p.".state") if -f $p.".state";
  my $r=$a->reconcile_state();
  die "reconcile failed\n" unless $r->{ok};
  die "reconcile did not repair missing state\n" unless $r->{repaired};

  my $v2=$a->verify_chain();
  die "post-reconcile verify failed\n" unless $v2->{ok};

  print "audit_s3_semantics=PASS records=$v2->{records} archives=$h->{archive_count} health=$h->{state}\n";
' "$TMP" || exit 1

rm -f "$TMP" "$TMP.state" "$TMP.anchor" "$TMP".*.jsonl

echo '== endpoint policy =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::EndpointPolicy -e '
  my $p=INPSan::Security::EndpointPolicy->new();
  for my $spec (
    ["GET","/api/v1/audit/health"],
    ["GET","/api/v1/audit/verify"],
    ["POST","/api/v1/audit/query"]
  ) {
    my $x=$p->lookup(@$spec);
    die "missing audit policy\n" unless $x;
    die "wrong audit permission\n" unless $x->{permission} eq "audit.read";
  }
  print "audit_endpoint_policy=PASS\n";
' || exit 1

echo '== wiring =='
grep -q "reconcile_state" "$CP" || exit 1
grep -q "/api/v1/audit/health" "$CP" || exit 1
grep -q "/api/v1/audit/verify" "$CP" || exit 1
grep -q "/api/v1/audit/query" "$CP" || exit 1
grep -q "audit.read" "$CP" || exit 1

echo 'INPSan S3 Audit Plane v0.2.4-dev verification: PASS'
echo 'Live OmniOS HTTP and benchmark evidence remain required before S3 PASS.'
