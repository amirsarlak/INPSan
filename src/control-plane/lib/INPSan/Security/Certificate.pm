package INPSan::Security::Certificate;

use strict;
use warnings;
use Fcntl qw(:mode);
use POSIX qw(strftime);

our $VERSION = '0.1.0-dev';

# Purpose:
#   Read-only certificate/key health inspection for the INPSan management plane.
#
# Security intent:
#   - never expose private-key material;
#   - verify restrictive key permissions;
#   - expose expiry/fingerprint metadata for operators/evaluators;
#   - keep certificate bootstrap separate from long-term enterprise PKI.

sub new {
    my ($class, %args) = @_;
    my $self = {
        cert_path => $args{cert_path},
        key_path => $args{key_path},
        openssl => $args{openssl} || '/usr/bin/openssl',
    };
    bless $self, $class;
    return $self;
}

sub health {
    my ($self) = @_;

    return { ok => 0, reason => 'cert_missing' }
        unless defined($self->{cert_path}) && -f $self->{cert_path};

    return { ok => 0, reason => 'key_missing' }
        unless defined($self->{key_path}) && -f $self->{key_path};

    my @ks = stat($self->{key_path});
    my $key_mode = @ks ? sprintf('%04o', S_IMODE($ks[2])) : undef;
    my $key_mode_ok = defined($key_mode) && $key_mode =~ /^(?:0400|0600)$/ ? 1 : 0;

    my ($meta, $rc) = _capture(
        $self->{openssl}, 'x509',
        '-in', $self->{cert_path},
        '-noout',
        '-subject',
        '-issuer',
        '-serial',
        '-enddate',
        '-fingerprint',
        '-sha256'
    );

    return {
        ok => 0,
        reason => 'openssl_x509_failed',
        key_mode => $key_mode,
        key_mode_ok => $key_mode_ok ? 1 : 0,
    } unless defined($meta) && $rc == 0;

    my ($subject) = $meta =~ /^subject=(.*)$/m;
    my ($issuer) = $meta =~ /^issuer=(.*)$/m;
    my ($serial) = $meta =~ /^serial=(.*)$/m;
    my ($not_after) = $meta =~ /^notAfter=(.*)$/m;
    my ($fingerprint) = $meta =~ /^sha256 Fingerprint=(.*)$/mi;

    my $expires_30d_ok = system(
        $self->{openssl}, 'x509',
        '-checkend', '2592000',
        '-noout',
        '-in', $self->{cert_path}
    ) == 0 ? 1 : 0;

    return {
        ok => $key_mode_ok ? 1 : 0,
        cert_path => $self->{cert_path},
        key_path => $self->{key_path},
        key_mode => $key_mode,
        key_mode_ok => $key_mode_ok ? 1 : 0,
        subject => $subject,
        issuer => $issuer,
        serial => $serial,
        not_after => $not_after,
        sha256_fingerprint => $fingerprint,
        expires_more_than_30d => $expires_30d_ok ? 1 : 0,
    };
}

sub _capture {
    my (@cmd) = @_;
    my $pid = open(my $fh, '-|');
    return (undef, 'fork_failed') unless defined $pid;
    if ($pid == 0) {
        open STDERR, '>&', STDOUT;
        exec @cmd;
        exit 127;
    }

    local $/;
    my $out = <$fh>;
    close $fh;
    my $rc = $? >> 8;
    return ($out, $rc);
}

1;
