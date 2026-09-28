package INPSan::Security::Audit;

use strict;
use warnings;
use JSON::PP qw(encode_json);
use Fcntl qw(:DEFAULT :flock);
use POSIX qw(strftime);
use Digest::SHA qw(sha256_hex);

our $VERSION = '0.1.0-dev';

# Purpose:
#   Canonical security audit writer for INPSan Control Plane.
#
# Security intent:
#   Produce attributable, version-bound, structured audit records for
#   authentication, authorization, configuration and privileged actions.
#
# Evidence intent:
#   Provide deterministic records suitable for AFTA/Common Criteria-oriented
#   testing, incident response and knowledge-based product evidence.
#
# Current limitation:
#   JSONL file output is a development evidence path. Integrity anchoring,
#   rotation/retention and secure export are SEC-IMP-03 follow-on items.

sub new {
    my ($class, %args) = @_;
    my $self = {
        path => $args{path} || '/var/tmp/inpsan-security-audit.jsonl',
        product_version => $args{product_version} || 'dev',
        source => $args{source} || 'control-plane',
    };
    bless $self, $class;
    return $self;
}

sub now_rfc3339 {
    return strftime('%Y-%m-%dT%H:%M:%SZ', gmtime());
}

sub write_event {
    my ($self, %e) = @_;

    my $event = {
        schema_version => '1.0',
        event_id => $e{event_id} || _event_id(),
        timestamp => $e{timestamp} || now_rfc3339(),
        actor_id => defined($e{actor_id}) ? $e{actor_id} : 'unknown',
        actor_type => $e{actor_type} || 'unknown',
        source => $e{source} || $self->{source},
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

    # Never accept obvious secret-bearing fields into the canonical schema.
    for my $forbidden (qw(password secret token access_token refresh_token private_key credential)) {
        die "forbidden audit field: $forbidden" if exists $e{$forbidden};
    }

    my $json = encode_json($event);
    sysopen(my $fh, $self->{path}, O_WRONLY|O_CREAT|O_APPEND, 0600)
        or die "cannot open audit log: $!";
    flock($fh, LOCK_EX) or die "cannot lock audit log: $!";
    print {$fh} $json, "\n";
    close $fh;
    chmod 0600, $self->{path};
    return $event->{event_id};
}

sub _event_id {
    my $seed = join(':', time(), $$, rand(), {});
    return 'evt-' . substr(sha256_hex($seed), 0, 24);
}

1;
