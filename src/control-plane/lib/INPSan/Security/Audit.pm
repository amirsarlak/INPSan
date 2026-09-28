package INPSan::Security::Audit;

use strict;
use warnings;
use JSON::PP qw(decode_json);
use Fcntl qw(:DEFAULT :flock SEEK_SET);
use POSIX qw(strftime);
use Digest::SHA qw(sha256_hex);

our $VERSION = '0.2.0-dev';

# Purpose:
#   Canonical security audit writer for INPSan Control Plane.
#
# Security intent:
#   Produce attributable, version-bound and tamper-evident audit records.
#
# Integrity model:
#   Each record contains sequence_number, previous_event_hash and event_hash.
#   event_hash = SHA-256(canonical JSON of the event without event_hash).
#
# Current limitation:
#   This local hash chain is tamper-evident, not immutable. Remote anchoring,
#   signed checkpoints, retention/rotation and secure export remain follow-on
#   requirements under SEC-IMP-03.

sub new {
    my ($class, %args) = @_;
    my $path = $args{path} || '/var/tmp/inpsan-security-audit.jsonl';
    my $self = {
        path => $path,
        state_path => $args{state_path} || $path . '.state',
        product_version => $args{product_version} || 'dev',
        source => $args{source} || 'control-plane',
        node_id => $args{node_id} || 'local',
        json => JSON::PP->new->canonical(1)->allow_nonref(1),
    };
    bless $self, $class;
    return $self;
}

sub now_rfc3339 {
    return strftime('%Y-%m-%dT%H:%M:%SZ', gmtime());
}

sub write_event {
    my ($self, %e) = @_;

    for my $forbidden (qw(password secret token access_token refresh_token private_key credential)) {
        die "forbidden audit field: $forbidden" if exists $e{$forbidden};
    }

    sysopen(my $sfh, $self->{state_path}, O_RDWR|O_CREAT, 0600)
        or die "cannot open audit state: $!";
    flock($sfh, LOCK_EX) or die "cannot lock audit state: $!";

    my $state = _read_state($self, $sfh);
    my $sequence = ($state->{sequence_number} || 0) + 1;
    my $previous = $state->{last_event_hash} || ('0' x 64);

    my $event = {
        schema_version => '1.1',
        event_id => $e{event_id} || _event_id(),
        timestamp => $e{timestamp} || now_rfc3339(),
        actor_id => defined($e{actor_id}) ? $e{actor_id} : 'unknown',
        actor_type => $e{actor_type} || 'unknown',
        source => $e{source} || $self->{source},
        node_id => $e{node_id} || $self->{node_id},
        sequence_number => $sequence,
        previous_event_hash => $previous,
        session_id => $e{session_id},
        correlation_id => $e{correlation_id},
        action => $e{action} || 'unknown',
        target_type => $e{target_type} || 'unknown',
        target_id => $e{target_id},
        permission => $e{permission},
        outcome => $e{outcome} || 'unknown',
        reason => $e{reason},
        client_context => $e{client_context},
        product_version => $self->{product_version},
    };

    my $canonical = $self->{json}->encode($event);
    $event->{event_hash} = sha256_hex($canonical);
    my $json = $self->{json}->encode($event);

    sysopen(my $fh, $self->{path}, O_WRONLY|O_CREAT|O_APPEND, 0600)
        or die "cannot open audit log: $!";
    flock($fh, LOCK_EX) or die "cannot lock audit log: $!";
    print {$fh} $json, "\n";
    close $fh;
    chmod 0600, $self->{path};

    my $new_state = {
        schema_version => '1.0',
        sequence_number => $sequence,
        last_event_hash => $event->{event_hash},
    };
    seek($sfh, 0, SEEK_SET);
    truncate($sfh, 0) or die "cannot truncate audit state: $!";
    print {$sfh} $self->{json}->encode($new_state), "\n";
    close $sfh;
    chmod 0600, $self->{state_path};

    return $event->{event_id};
}

sub verify_chain {
    my ($self) = @_;
    return {
        ok => 1,
        records => 0,
        last_event_hash => ('0' x 64),
    } unless -f $self->{path};

    open my $fh, '<', $self->{path} or return {
        ok => 0,
        reason => 'open_failed',
    };

    my $expected_prev = '0' x 64;
    my $expected_seq = 1;
    my $count = 0;

    while (my $line = <$fh>) {
        chomp $line;
        next unless length($line);

        my $event = eval { decode_json($line) };
        if (!$event || ref($event) ne 'HASH') {
            close $fh;
            return { ok => 0, reason => 'invalid_json', record => $count + 1 };
        }

        if (($event->{sequence_number} || 0) != $expected_seq) {
            close $fh;
            return { ok => 0, reason => 'sequence_mismatch', record => $count + 1 };
        }

        if (($event->{previous_event_hash} || '') ne $expected_prev) {
            close $fh;
            return { ok => 0, reason => 'previous_hash_mismatch', record => $count + 1 };
        }

        my $stored_hash = delete $event->{event_hash};
        my $calculated = sha256_hex($self->{json}->encode($event));

        if (!defined($stored_hash) || $stored_hash ne $calculated) {
            close $fh;
            return { ok => 0, reason => 'event_hash_mismatch', record => $count + 1 };
        }

        $expected_prev = $stored_hash;
        $expected_seq++;
        $count++;
    }

    close $fh;
    return {
        ok => 1,
        records => $count,
        last_event_hash => $expected_prev,
    };
}

sub _read_state {
    my ($self, $fh) = @_;
    seek($fh, 0, SEEK_SET);
    local $/;
    my $raw = <$fh>;
    return {} unless defined($raw) && $raw =~ /\S/;

    my $obj = eval { decode_json($raw) };
    return {} unless $obj && ref($obj) eq 'HASH';
    return $obj;
}

sub _event_id {
    my $seed = join(':', time(), $$, rand(), {});
    return 'evt-' . substr(sha256_hex($seed), 0, 24);
}

1;
