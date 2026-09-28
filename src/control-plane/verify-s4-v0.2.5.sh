#!/usr/bin/bash
# INPSan S4 TLS/session/certificate verification — v0.2.5-dev
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"
CP="$BASE/inpsan-control-plane-v0.2.5-dev.pl"
AUTH="$LIB/INPSan/Security/Auth.pm"
CERTMOD="$LIB/INPSan/Security/Certificate.pm"
POLICY="$LIB/INPSan/Security/EndpointPolicy.pm"

echo '== syntax =='
/usr/bin/perl -I"$LIB" -c "$AUTH" || exit 1
/usr/bin/perl -I"$LIB" -c "$CERTMOD" || exit 1
/usr/bin/perl -I"$LIB" -c "$POLICY" || exit 1
/usr/bin/perl -I"$LIB" -c "$CP" || exit 1

echo '== endpoint policy =='
/usr/bin/perl -I"$LIB" -MINPSan::Security::EndpointPolicy -e '
  my $p=INPSan::Security::EndpointPolicy->new();
  my $x=$p->lookup("GET","/api/v1/security/tls");
  die "missing TLS endpoint policy\n" unless $x;
  die "wrong TLS permission\n" unless $x->{permission} eq "security.read";
  print "tls_endpoint_policy=PASS\n";
' || exit 1

echo '== session idle timeout =='
TMP="/var/tmp/inpsan-s4-auth-$$.json"
/usr/bin/perl -I"$LIB" -MINPSan::Security::Auth -e '
  my $p=$ARGV[0];
  my $a=INPSan::Security::Auth->new(
    user_store=>$p,
    idle_timeout=>1,
    absolute_timeout=>10,
    iterations=>100000
  );
  $a->create_user(
    username=>"idle_test",
    password=>"S4-Idle-Test-Password-123!",
    roles=>["viewer"],
    scopes=>["node:local"]
  );
  my $u=$a->find_user("idle_test");
  my $t=$a->issue_session($u);
  my ($ok,$s)=$a->validate_session($t);
  die "immediate session invalid\n" unless $ok && $s->{session_id};
  sleep 2;
  my ($ok2,undef,$reason)=$a->validate_session($t);
  die "idle session did not expire\n" if $ok2;
  die "wrong idle reason\n" unless $reason eq "expired_session";
  print "idle_timeout=PASS\n";
' "$TMP" || exit 1
rm -f "$TMP"

echo '== session absolute timeout =='
TMP="/var/tmp/inpsan-s4-auth-abs-$$.json"
/usr/bin/perl -I"$LIB" -MINPSan::Security::Auth -e '
  my $p=$ARGV[0];
  my $a=INPSan::Security::Auth->new(
    user_store=>$p,
    idle_timeout=>20,
    absolute_timeout=>2,
    iterations=>100000
  );
  $a->create_user(
    username=>"abs_test",
    password=>"S4-Absolute-Test-Password-123!",
    roles=>["viewer"],
    scopes=>["node:local"]
  );
  my $u=$a->find_user("abs_test");
  my $t=$a->issue_session($u);
  sleep 3;
  my ($ok,undef,$reason)=$a->validate_session($t);
  die "absolute session did not expire\n" if $ok;
  die "wrong absolute reason\n" unless $reason eq "expired_session";
  print "absolute_timeout=PASS\n";
' "$TMP" || exit 1
rm -f "$TMP"

echo '== secure cookie / headers wiring =='
grep -q "__Host-INPSAN_SESSION" "$CP" || exit 1
grep -q "Secure; HttpOnly; SameSite=Strict" "$CP" || exit 1
grep -q "Strict-Transport-Security" "$CP" || exit 1
grep -q "Content-Security-Policy" "$CP" || exit 1
grep -q "Permissions-Policy" "$CP" || exit 1
grep -q "TLSv12:TLSv13" "$CP" || exit 1
grep -q "IO::Socket::SSL" "$CP" || exit 1
grep -q "Certificate->new" "$CP" || exit 1

echo 'INPSan S4 TLS/session/certificate static verification: PASS'
echo 'Live OmniOS TLS/cookie/protocol evidence remains required before S4 PASS.'
