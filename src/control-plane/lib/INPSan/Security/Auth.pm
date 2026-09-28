package INPSan::Security::Auth;

use strict;
use warnings;
use Digest::SHA qw(hmac_sha256 sha256_hex);
use JSON::PP qw(encode_json decode_json);
use MIME::Base64 qw(encode_base64 decode_base64);
use Fcntl qw(:DEFAULT :flock);
use File::Basename qw(dirname);
use File::Path qw(make_path);
use Time::HiRes qw(time);

our $VERSION = '0.2.0-dev';

# Purpose:
#   Independent INPSan local identity/authentication primitive for the 3.3
#   Control Plane. This module deliberately does not depend on napp-it auth.
#
# Security impact:
#   Handles password verifiers, session-token generation/verification and
#   local named-principal lookup. Passwords and bearer tokens must never be
#   logged by callers.
#
# Related:
#   docs/11-security/CONTROL_PLANE_SECURITY_CONTRACT_V1.md
#   docs/11-security/SFR_TRACEABILITY_BASELINE_V0.1.md
#   docs/06-decisions/ADR-0013-INDEPENDENT-IDENTITY-AUTH.md

my $DEFAULT_ITERATIONS = 600_000;
my $SALT_BYTES = 16;
my $TOKEN_BYTES = 32;

sub new {
    my ($class, %args) = @_;
    my $self = {
        user_store => $args{user_store} || '/var/opt/inpsan/security/users.json',
        sessions   => {},
        idle_timeout => $args{idle_timeout} || 900,
        absolute_timeout => $args{absolute_timeout} || 28800,
        iterations => $args{iterations} || $DEFAULT_ITERATIONS,
    };
    bless $self, $class;
    return $self;
}

sub user_store_path { return $_[0]->{user_store}; }

sub random_bytes {
    my ($n) = @_;
    open my $fh, '<:raw', '/dev/urandom' or die "cannot open secure random source: $!";
    my $buf = '';
    my $got = read($fh, $buf, $n);
    close $fh;
    die "secure random source short read" unless defined($got) && $got == $n;
    return $buf;
}

sub pbkdf2_hmac_sha256 {
    my ($password, $salt, $iterations, $dklen) = @_;
    die "invalid iterations" unless defined($iterations) && $iterations >= 100_000;
    $dklen ||= 32;

    my $hlen = 32;
    my $blocks = int(($dklen + $hlen - 1) / $hlen);
    my $out = '';

    for my $i (1 .. $blocks) {
        my $u = hmac_sha256($salt . pack('N', $i), $password);
        my $t = $u;
        for (2 .. $iterations) {
            $u = hmac_sha256($u, $password);
            $t = $t ^ $u;
        }
        $out .= $t;
    }
    return substr($out, 0, $dklen);
}

sub constant_time_eq {
    my ($a, $b) = @_;
    return 0 unless defined($a) && defined($b);
    return 0 unless length($a) == length($b);
    my $diff = 0;
    for my $i (0 .. length($a) - 1) {
        $diff |= ord(substr($a,$i,1)) ^ ord(substr($b,$i,1));
    }
    return $diff == 0 ? 1 : 0;
}

sub hash_password {
    my ($self, $password) = @_;
    die "password required" unless defined($password) && length($password) > 0;

    my $salt = random_bytes($SALT_BYTES);
    my $dk = pbkdf2_hmac_sha256($password, $salt, $self->{iterations}, 32);

    return join('$',
        'pbkdf2-sha256',
        $self->{iterations},
        encode_base64($salt, ''),
        encode_base64($dk, '')
    );
}

sub verify_password {
    my ($self, $password, $encoded) = @_;
    return 0 unless defined($password) && defined($encoded);
    my ($scheme, $iter, $salt64, $hash64) = split /\$/, $encoded, 4;
    return 0 unless defined($scheme) && $scheme eq 'pbkdf2-sha256';
    return 0 unless defined($iter) && $iter =~ /^\d+$/ && $iter >= 100_000;
    return 0 unless defined($salt64) && defined($hash64);

    my $salt = eval { decode_base64($salt64) };
    my $expected = eval { decode_base64($hash64) };
    return 0 unless defined($salt) && defined($expected) && length($expected) == 32;

    my $actual = pbkdf2_hmac_sha256($password, $salt, 0 + $iter, 32);
    return constant_time_eq($actual, $expected);
}

sub _empty_store {
    return {
        schema_version => '1.0',
        users => [],
    };
}

sub load_store {
    my ($self) = @_;
    my $path = $self->{user_store};
    return _empty_store() unless -f $path;

    open my $fh, '<', $path or die "cannot read user store: $!";
    flock($fh, LOCK_SH) or die "cannot lock user store: $!";
    local $/;
    my $raw = <$fh>;
    close $fh;

    my $obj = decode_json($raw);
    die "invalid user store schema" unless ref($obj) eq 'HASH' && ref($obj->{users}) eq 'ARRAY';
    return $obj;
}

sub save_store {
    my ($self, $store) = @_;
    my $path = $self->{user_store};
    my $dir = dirname($path);
    make_path($dir, { mode => 0700 }) unless -d $dir;

    my $tmp = "$path.tmp.$$";
    sysopen(my $fh, $tmp, O_WRONLY|O_CREAT|O_EXCL, 0600)
        or die "cannot create user store temp file: $!";
    flock($fh, LOCK_EX) or die "cannot lock user store temp file: $!";
    print {$fh} encode_json($store);
    print {$fh} "\n";
    close $fh;
    chmod 0600, $tmp or die "cannot chmod user store: $!";
    rename $tmp, $path or die "cannot replace user store: $!";
    chmod 0600, $path or die "cannot chmod user store: $!";
    return 1;
}

sub validate_username {
    my ($username) = @_;
    return defined($username) && $username =~ /\A[a-zA-Z0-9][a-zA-Z0-9._-]{2,63}\z/;
}

sub create_user {
    my ($self, %args) = @_;
    my $username = $args{username};
    my $password = $args{password};
    my $roles = $args{roles} || ['viewer'];
    my $scopes = $args{scopes} || ['node:local'];

    die "invalid username" unless validate_username($username);
    die "password required" unless defined($password) && length($password) >= 12;
    die "roles must be array" unless ref($roles) eq 'ARRAY' && @$roles;
    die "scopes must be array" unless ref($scopes) eq 'ARRAY' && @$scopes;

    my $store = $self->load_store();
    for my $u (@{$store->{users}}) {
        die "user already exists" if lc($u->{username}) eq lc($username);
    }

    push @{$store->{users}}, {
        user_id => 'usr-' . substr(sha256_hex(random_bytes(32)), 0, 24),
        username => $username,
        password_verifier => $self->hash_password($password),
        roles => $roles,
        scopes => $scopes,
        enabled => JSON::PP::true,
        created_at_epoch => 0 + int(time()),
    };
    $self->save_store($store);
    return 1;
}

sub find_user {
    my ($self, $username) = @_;
    return undef unless validate_username($username);
    my $store = $self->load_store();
    for my $u (@{$store->{users}}) {
        return $u if lc($u->{username}) eq lc($username);
    }
    return undef;
}

sub authenticate {
    my ($self, $username, $password) = @_;
    my $u = $self->find_user($username);
    return (0, undef, 'invalid_credentials') unless $u && $u->{enabled};
    return (0, undef, 'invalid_credentials')
        unless $self->verify_password($password, $u->{password_verifier});
    return (1, $u, 'ok');
}

sub issue_session {
    my ($self, $user) = @_;
    die "user required" unless ref($user) eq 'HASH' && $user->{user_id};

    my $token = encode_base64(random_bytes($TOKEN_BYTES), '');
    $token =~ tr|+/|_-|;
    $token =~ s/=+\z//;

    my $key = sha256_hex($token);
    my $now = time();
    $self->{sessions}{$key} = {
        user_id => $user->{user_id},
        username => $user->{username},
        roles => $user->{roles},
        scopes => $user->{scopes} || ['node:local'],
        created_at => $now,
        last_seen => $now,
        absolute_expires_at => $now + $self->{absolute_timeout},
    };
    return $token;
}

sub validate_session {
    my ($self, $token) = @_;
    return (0, undef, 'missing_token') unless defined($token) && length($token) >= 32;

    my $key = sha256_hex($token);
    my $s = $self->{sessions}{$key};
    return (0, undef, 'invalid_session') unless $s;

    my $now = time();
    if ($now > $s->{absolute_expires_at} || ($now - $s->{last_seen}) > $self->{idle_timeout}) {
        delete $self->{sessions}{$key};
        return (0, undef, 'expired_session');
    }

    $s->{last_seen} = $now;
    return (1, $s, 'ok');
}

sub revoke_session {
    my ($self, $token) = @_;
    return 0 unless defined($token);
    my $key = sha256_hex($token);
    return delete($self->{sessions}{$key}) ? 1 : 0;
}

1;
