#!/usr/bin/bash
# INPSan SEC-IMP-02 role/capability/scope negative matrix
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"

echo '== Role capability matrix =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::RBAC -e '
  my $r=INPSan::Security::RBAC->new();

  my %expect = (
    viewer => {
      allow => [qw(system.read health.read storage.read topology.read performance.read alerts.read events.read reports.read)],
      deny  => [qw(storage.manage alerts.ack alerts.silence audit.read security.manage users.manage roles.manage updates.manage fleet.manage)],
    },
    operator => {
      allow => [qw(system.read health.read storage.read alerts.read alerts.ack alerts.silence events.read reports.read)],
      deny  => [qw(storage.manage audit.read security.manage users.manage roles.manage updates.manage fleet.manage)],
    },
    "storage-admin" => {
      allow => [qw(system.read health.read storage.read storage.manage topology.read performance.read alerts.read alerts.ack reports.manage)],
      deny  => [qw(security.manage users.manage roles.manage updates.manage fleet.manage)],
    },
    "security-admin" => {
      allow => [qw(system.read health.read audit.read security.read security.manage users.manage roles.manage updates.manage)],
      deny  => [qw(storage.read storage.manage topology.read performance.read fleet.manage)],
    },
    auditor => {
      allow => [qw(system.read health.read storage.read topology.read alerts.read events.read reports.read audit.read security.read)],
      deny  => [qw(storage.manage security.manage users.manage roles.manage updates.manage fleet.manage)],
    },
    "platform-admin" => {
      allow => [qw(system.read health.read storage.read storage.manage topology.read performance.read alerts.read alerts.ack alerts.silence events.read reports.read reports.manage audit.read security.read security.manage users.manage roles.manage updates.manage fleet.read fleet.manage)],
      deny  => [],
    },
  );

  for my $role (sort keys %expect) {
    for my $cap (@{$expect{$role}{allow}}) {
      die "$role should allow $cap\n" unless $r->has_capability([$role],$cap);
    }
    for my $cap (@{$expect{$role}{deny}}) {
      die "$role should deny $cap\n" if $r->has_capability([$role],$cap);
    }
  }

  my $unknown=$r->authorize(roles=>["not-a-role"],required_capability=>"system.read");
  die "unknown role must deny\n" if $unknown->{allowed};

  my $missing=$r->authorize(roles=>[],required_capability=>"system.read");
  die "empty role list must deny\n" if $missing->{allowed};

  print "role_matrix=PASS\n";
' || exit 1

echo '== Scope matrix =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::Scope -e '
  my $s=INPSan::Security::Scope->new();

  my $ok=$s->allows(
    grants=>["pool:Pool-1800GB","node:local"],
    required_scope=>"pool:Pool-1800GB"
  );
  die "exact pool scope should allow\n" unless $ok->{allowed};

  my $wrong=$s->allows(
    grants=>["pool:Pool-300G","node:local"],
    required_scope=>"pool:Pool-1800GB"
  );
  die "different pool scope must deny\n" if $wrong->{allowed};

  my $node=$s->allows(
    grants=>["node:local"],
    required_scope=>"pool:Pool-1800GB"
  );
  die "node scope must not implicitly grant pool scope in v0.1\n" if $node->{allowed};

  die "invalid path-like scope accepted\n" if $s->valid_scope("../../etc/passwd");
  die "invalid type accepted\n" if $s->valid_scope("unknown:value");

  print "scope_matrix=PASS\n";
' || exit 1

echo '== Dynamic endpoint policy =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::EndpointPolicy -e '
  my $p=INPSan::Security::EndpointPolicy->new();
  my $x=$p->lookup("GET","/api/v1/storage/pools/Pool-1800GB");
  die "pool detail policy missing\n" unless $x;
  die "wrong permission\n" unless $x->{permission} eq "storage.read";
  die "scope not required\n" unless $x->{scope_required};
  die "wrong scope\n" unless $x->{required_scope} eq "pool:Pool-1800GB";

  die "unsafe pool identifier accepted\n"
    if $p->lookup("GET","/api/v1/storage/pools/../../etc/passwd");

  print "endpoint_scope_policy=PASS\n";
' || exit 1

echo 'INPSan SEC-IMP-02 role/scope matrix static verification: PASS'
echo 'Live HTTP authorization evidence on OmniOS remains required before S2 PASS.'
