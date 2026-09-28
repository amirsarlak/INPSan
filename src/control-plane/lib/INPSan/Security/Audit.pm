package INPSan::Security::Audit;

use strict;
use warnings;
use JSON::PP qw(decode_json);
use Fcntl qw(:DEFAULT :flock SEEK_SET);
use POSIX qw(strftime);
use Digest::SHA qw(sha256_hex);
use File::Basename qw(dirname);

our $VERSION = '0.3.0-dev';

# Purpose:
#   Product-grade security audit primitive for the INPSan Control Plane.
#
# Security model:
#   - canonical JSON records;
#   - monotonic sequence numbers;
#   - SHA-256 previous-hash chaining;
#   - tamper verification across rotated files;
#   - bounded active-file size;
#   - explicit capacity health;
#   - retention anchors when old archives are removed;
#   - startup state reconciliation only after chain verification.
#
# Current limitation:
#   Local hash chaining is tamper-evident, not immutable. Remote authenticated
#   export / signed anchoring remains a separate evaluation-strength control.

sub new {
    my ($class, %args) = @_;
    my $path = $args{path} || '/var/tmp/inpsan-security-audit.jsonl';
    my $self = {
        path => $path,
        state_path => $args{state_path} || $path . '.state',
        anchor_path => $args{anchor_path} || $path . '.anchor',
        product_version => $args{product_version} || 'dev',
        source => $args{source} || 'control-plane',
        node_id => $args{node_id} || 'local',
        max_file_bytes => $args{max_file_bytes} || (10 * 1024 * 1024),
        warning_ratio => defined($args{warning_ratio}) ? $args{warning_ratio} : 0.80,
        critical_ratio => defined($args{critical_ratio}) ? $args{critical_ratio} : 0.95,
        max_archives => defined($args{max_archives}) ? $args{max_archives} : 10,
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

    my $state = _read_json_fh($self, $sfh);
    $state = {} unless ref($state) eq 'HASH';

    my $sequence = ($state->{sequence_number} || 0) + 1;
    my $previous = $state->{last_event_hash} || _initial_previous_hash($self);

    my $event = {
        schema_version => '1.2',
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
        event_class => $e{event_class} || 'operational',
        product_version => $self->{product_version},
    };

    my $canonical = $self->{json}->encode($event);
    $event->{event_hash} = sha256_hex($canonical);
    my $json = $self->{json}->encode($event) . "\n";

    _rotate_if_needed($self, $state, length($json));

    sysopen(my $fh, $self->{path}, O_WRONLY|O_CREAT|O_APPEND, 0600)
        or die "cannot open audit log: $!";
    flock($fh, LOCK_EX) or die "cannot lock audit log: $!";
    print {$fh} $json;
    close $fh;
    chmod 0600, $self->{path};

    my $new_state = {
        schema_version => '1.1',
        sequence_number => $sequence,
        last_event_hash => $event->{event_hash},
        updated_at => now_rfc3339(),
    };
    _rewrite_locked_json($self, $sfh, $new_state);
    close $sfh;
    chmod 0600, $self->{state_path};

    return $event->{event_id};
}

sub health {
    my ($self) = @_;
    my $size = -f $self->{path} ? (-s $self->{path}) : 0;
    my $max = $self->{max_file_bytes};
    my $ratio = $max > 0 ? ($size / $max) : 0;

    my $state = 'OK';
    $state = 'CRITICAL' if $ratio >= $self->{critical_ratio};
    $state = 'WARNING' if $state eq 'OK' && $ratio >= $self->{warning_ratio};

    my @archives = _archive_files($self);

    return {
        state => $state,
        active_file_bytes => 0 + $size,
        max_file_bytes => 0 + $max,
        utilization_ratio => 0 + sprintf('%.6f', $ratio),
        archive_count => scalar(@archives),
        max_archives => 0 + $self->{max_archives},
        path => $self->{path},
    };
}

sub verify_chain {
    my ($self) = @_;

    my $anchor = _read_json_path($self, $self->{anchor_path});
    my $expected_seq = ($anchor && $anchor->{next_sequence}) ? $anchor->{next_sequence} : 1;
    my $expected_prev = ($anchor && $anchor->{previous_event_hash})
        ? $anchor->{previous_event_hash}
        : ('0' x 64);

    my @files = (_archive_files($self));
    push @files, $self->{path} if -f $self->{path};

    my $count = 0;
    my $last_hash = $expected_prev;
    my $last_seq = $expected_seq - 1;

    for my $path (@files) {
        open my $fh, '<', $path or return {
            ok => 0, reason => 'open_failed', file => $path
        };

        while (my $line = <$fh>) {
            chomp $line;
            next unless length($line);

            my $event = eval { decode_json($line) };
            if (!$event || ref($event) ne 'HASH') {
                close $fh;
                return { ok => 0, reason => 'invalid_json', record => $count + 1, file => $path };
            }

            if (($event->{sequence_number} || 0) != $expected_seq) {
                close $fh;
                return { ok => 0, reason => 'sequence_mismatch', record => $count + 1, file => $path };
            }

            if (($event->{previous_event_hash} || '') ne $expected_prev) {
                close $fh;
                return { ok => 0, reason => 'previous_hash_mismatch', record => $count + 1, file => $path };
            }

            my $stored_hash = delete $event->{event_hash};
            my $calculated = sha256_hex($self->{json}->encode($event));
            if (!defined($stored_hash) || $stored_hash ne $calculated) {
                close $fh;
                return { ok => 0, reason => 'event_hash_mismatch', record => $count + 1, file => $path };
            }

            $expected_prev = $stored_hash;
            $last_hash = $stored_hash;
            $last_seq = $expected_seq;
            $expected_seq++;
            $count++;
        }
        close $fh;
    }

    return {
        ok => 1,
        records => $count,
        last_event_hash => $last_hash,
        last_sequence_number => $last_seq,
        anchor_in_use => $anchor ? JSON::PP::true : JSON::PP::false,
    };
}

sub reconcile_state {
    my ($self) = @_;
    my $v = $self->verify_chain();
    return {
        ok => 0,
        reason => 'audit_chain_invalid',
        detail => $v,
    } unless $v->{ok};

    my $current = _read_json_path($self, $self->{state_path}) || {};
    my $seq = $v->{last_sequence_number} || 0;
    my $hash = $v->{last_event_hash} || _initial_previous_hash($self);

    if (($current->{sequence_number} || 0) == $seq &&
        ($current->{last_event_hash} || '') eq $hash) {
        return { ok => 1, repaired => JSON::PP::false, sequence_number => $seq };
    }

    _write_json_path($self, $self->{state_path}, {
        schema_version => '1.1',
        sequence_number => $seq,
        last_event_hash => $hash,
        updated_at => now_rfc3339(),
        reconciliation => 'verified_chain',
    });

    return { ok => 1, repaired => JSON::PP::true, sequence_number => $seq };
}

sub query_events {
    my ($self, %q) = @_;
    my $limit = $q{limit};
    $limit = 100 unless defined($limit) && $limit =~ /^\d+$/ && $limit >= 1 && $limit <= 1000;

    my @files = (_archive_files($self));
    push @files, $self->{path} if -f $self->{path};

    my @events;
    for my $path (@files) {
        open my $fh, '<', $path or next;
        while (my $line = <$fh>) {
            chomp $line;
            next unless length($line);
            my $event = eval { decode_json($line) };
            next unless $event && ref($event) eq 'HASH';

            next if defined($q{actor_id}) && ($event->{actor_id} || '') ne $q{actor_id};
            next if defined($q{action}) && ($event->{action} || '') ne $q{action};
            next if defined($q{outcome}) && ($event->{outcome} || '') ne $q{outcome};
            next if defined($q{target_type}) && ($event->{target_type} || '') ne $q{target_type};
            push @events, $event;
        }
        close $fh;
    }

    @events = sort {
        ($b->{sequence_number} || 0) <=> ($a->{sequence_number} || 0)
    } @events;

    splice(@events, $limit) if @events > $limit;
    return \@events;
}

sub _rotate_if_needed {
    my ($self, $state, $incoming_bytes) = @_;
    return unless -f $self->{path};

    my $size = -s $self->{path};
    return if ($size + $incoming_bytes) <= $self->{max_file_bytes};

    my $last_seq = $state->{sequence_number} || 0;
    return if $last_seq <= 0;

    my $archive = sprintf('%s.%012d.jsonl', $self->{path}, $last_seq);
    rename($self->{path}, $archive) or die "cannot rotate audit log: $!";
    chmod 0600, $archive;

    _enforce_retention($self);
}

sub _enforce_retention {
    my ($self) = @_;
    my @archives = _archive_files($self);
    return if @archives <= $self->{max_archives};

    my $remove_count = @archives - $self->{max_archives};
    my @remove = splice(@archives, 0, $remove_count);
    my ($last_deleted_seq, $last_deleted_hash);

    for my $path (@remove) {
        open my $fh, '<', $path or die "cannot read archive before retention: $!";
        while (my $line = <$fh>) {
            chomp $line;
            next unless length($line);
            my $event = eval { decode_json($line) };
            next unless $event && ref($event) eq 'HASH';
            $last_deleted_seq = $event->{sequence_number};
            $last_deleted_hash = $event->{event_hash};
        }
        close $fh;
        unlink($path) or die "cannot delete expired audit archive: $!";
    }

    if (defined($last_deleted_seq) && defined($last_deleted_hash)) {
        _write_json_path($self, $self->{anchor_path}, {
            schema_version => '1.0',
            deleted_through_sequence => 0 + $last_deleted_seq,
            next_sequence => 0 + $last_deleted_seq + 1,
            previous_event_hash => $last_deleted_hash,
            created_at => now_rfc3339(),
        });
    }
}

sub _archive_files {
    my ($self) = @_;
    my @files = glob($self->{path} . '.*.jsonl');
    @files = sort {
        my ($as) = $a =~ /\.(\d+)\.jsonl\z/;
        my ($bs) = $b =~ /\.(\d+)\.jsonl\z/;
        ($as || 0) <=> ($bs || 0);
    } @files;
    return @files;
}

sub _initial_previous_hash {
    my ($self) = @_;
    my $anchor = _read_json_path($self, $self->{anchor_path});
    return $anchor->{previous_event_hash}
        if $anchor && $anchor->{previous_event_hash};
    return '0' x 64;
}

sub _read_json_fh {
    my ($self, $fh) = @_;
    seek($fh, 0, SEEK_SET);
    local $/;
    my $raw = <$fh>;
    return {} unless defined($raw) && $raw =~ /\S/;
    my $obj = eval { decode_json($raw) };
    return $obj && ref($obj) eq 'HASH' ? $obj : {};
}

sub _read_json_path {
    my ($self, $path) = @_;
    return undef unless -f $path;
    open my $fh, '<', $path or return undef;
    local $/;
    my $raw = <$fh>;
    close $fh;
    return undef unless defined($raw) && $raw =~ /\S/;
    my $obj = eval { decode_json($raw) };
    return $obj && ref($obj) eq 'HASH' ? $obj : undef;
}

sub _write_json_path {
    my ($self, $path, $obj) = @_;
    my $tmp = $path . '.tmp.' . $$;
    sysopen(my $fh, $tmp, O_WRONLY|O_CREAT|O_EXCL, 0600)
        or die "cannot create json temp file: $!";
    print {$fh} $self->{json}->encode($obj), "\n";
    close $fh;
    chmod 0600, $tmp;
    rename($tmp, $path) or die "cannot replace json file: $!";
    chmod 0600, $path;
}

sub _rewrite_locked_json {
    my ($self, $fh, $obj) = @_;
    seek($fh, 0, SEEK_SET);
    truncate($fh, 0) or die "cannot truncate json state: $!";
    print {$fh} $self->{json}->encode($obj), "\n";
}

sub _event_id {
    my $seed = join(':', time(), $$, rand(), {});
    return 'evt-' . substr(sha256_hex($seed), 0, 24);
}

1;
