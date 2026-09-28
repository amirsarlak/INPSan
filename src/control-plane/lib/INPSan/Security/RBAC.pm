package INPSan::Security::RBAC;

use strict;
use warnings;

our $VERSION = '0.1.0-dev';

# Purpose:
#   Capability-based authorization for INPSan Control Plane.
#
# Design:
#   - deny by default;
#   - role names are mappings, not authorization logic;
#   - endpoint/action code asks for capabilities;
#   - object/scope evaluation is a separate step and remains mandatory.
#
# Related:
#   docs/11-security/CONTROL_PLANE_SECURITY_CONTRACT_V1.md
#   docs/11-security/SFR_TRACEABILITY_BASELINE_V0.1.md
#   CP-3.3-FINAL-001

my %ROLE_CAPS = (
    'viewer' => {
        map { $_ => 1 } qw(
          system.read health.read storage.read topology.read
          performance.read alerts.read events.read reports.read
        )
    },
    'operator' => {
        map { $_ => 1 } qw(
          system.read health.read storage.read topology.read
          performance.read alerts.read alerts.ack alerts.silence
          events.read reports.read
        )
    },
    'storage-admin' => {
        map { $_ => 1 } qw(
          system.read health.read storage.read storage.manage
          topology.read performance.read alerts.read alerts.ack
          events.read reports.read reports.manage
        )
    },
    'security-admin' => {
        map { $_ => 1 } qw(
          system.read health.read alerts.read events.read reports.read
          audit.read security.read security.manage users.manage roles.manage
          updates.manage
        )
    },
    'auditor' => {
        map { $_ => 1 } qw(
          system.read health.read storage.read topology.read
          alerts.read events.read reports.read audit.read security.read
        )
    },
    'platform-admin' => {
        map { $_ => 1 } qw(
          system.read health.read storage.read storage.manage topology.read
          performance.read alerts.read alerts.ack alerts.silence
          events.read reports.read reports.manage audit.read security.read
          security.manage users.manage roles.manage updates.manage
          fleet.read fleet.manage
        )
    },
);

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub role_capabilities {
    my ($self, $role) = @_;
    return {} unless defined($role) && exists $ROLE_CAPS{$role};
    return { %{$ROLE_CAPS{$role}} };
}

sub effective_capabilities {
    my ($self, $roles) = @_;
    my %caps;
    return \%caps unless ref($roles) eq 'ARRAY';
    for my $role (@$roles) {
        next unless defined($role) && exists $ROLE_CAPS{$role};
        $caps{$_} = 1 for keys %{$ROLE_CAPS{$role}};
    }
    return \%caps;
}

sub has_capability {
    my ($self, $roles, $required) = @_;
    return 0 unless defined($required) && length($required);
    my $caps = $self->effective_capabilities($roles);
    return $caps->{$required} ? 1 : 0;
}

sub authorize {
    my ($self, %args) = @_;

    my $roles = $args{roles};
    my $required = $args{required_capability};

    return {
        allowed => 0,
        reason => 'missing_principal_roles',
    } unless ref($roles) eq 'ARRAY';

    return {
        allowed => 0,
        reason => 'missing_required_capability',
    } unless defined($required) && length($required);

    return {
        allowed => 0,
        reason => 'capability_denied',
        required_capability => $required,
    } unless $self->has_capability($roles, $required);

    # Object/site/node scope checks are intentionally not inferred here.
    # Callers must supply a separate scope decision once scoped resources
    # are introduced. Treat absent future scope evaluation as deny.
    if (exists $args{scope_required} && $args{scope_required}) {
        return {
            allowed => 0,
            reason => 'scope_not_evaluated',
            required_capability => $required,
        } unless exists $args{scope_allowed};

        return {
            allowed => 0,
            reason => 'scope_denied',
            required_capability => $required,
        } unless $args{scope_allowed};
    }

    return {
        allowed => 1,
        reason => 'authorized',
        required_capability => $required,
    };
}

sub known_roles {
    return [ sort keys %ROLE_CAPS ];
}

1;
