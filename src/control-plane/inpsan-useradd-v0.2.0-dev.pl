#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Getopt::Long qw(GetOptions);
use Term::ReadKey;
use INPSan::Security::Auth;

# Purpose:
#   Offline/local provisioning of named INPSan users.
# Security:
#   Password is read from TTY without echo and is never accepted on argv.

my ($username, $role, $store, $help);
$role = 'platform-admin';
GetOptions(
    'username=s' => \$username,
    'role=s'     => \$role,
    'store=s'    => \$store,
    'help'       => \$help,
) or die "invalid arguments\n";

if ($help || !$username) {
    print "Usage: $0 --username NAME [--role ROLE] [--store PATH]\n";
    exit($help ? 0 : 2);
}

my %allowed_role = map { $_ => 1 } qw(viewer operator storage-admin security-admin auditor platform-admin);
die "invalid role\n" unless $allowed_role{$role};

print "Password: ";
ReadMode('noecho');
my $p1 = <STDIN>;
ReadMode('restore');
print "\nConfirm password: ";
ReadMode('noecho');
my $p2 = <STDIN>;
ReadMode('restore');
print "\n";
chomp($p1 //= '');
chomp($p2 //= '');

die "password mismatch\n" unless $p1 eq $p2;
die "password must be at least 12 characters\n" unless length($p1) >= 12;

my %args;
$args{user_store} = $store if defined $store;
my $auth = INPSan::Security::Auth->new(%args);
$auth->create_user(username => $username, password => $p1, roles => [$role]);

$p1 = '';
$p2 = '';
print "user_created=PASS username=$username role=$role\n";
