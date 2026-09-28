package INPSan::Security::Scope;

use strict;
use warnings;

our $VERSION = '0.1.0-dev';

# Purpose:
#   Evaluate resource scope independently from role/capability.
#
# Model:
#   Scope strings are canonical hierarchical identifiers:
#     node:<node-id>
#     pool:<pool-id>
#     dataset:<pool-id>/<dataset>
#     lun:<lun-id>
#     share:<share-id>
#     site:<site-id>
#
#   The initial single-node product uses exact scope identifiers.
#   Wildcard/tenant inheritance is deliberately deferred until Central Manager
#   scope semantics are formally defined and tested.
#
# Security intent:
#   Keep object authorization separate from role mapping so a storage-admin
#   with storage.manage cannot automatically manage every object/site/node.

sub new { return bless {}, $_[0]; }

sub valid_scope {
    my ($self, $scope) = @_;
    return 0 unless defined($scope);
    return $scope =~ m{\A(?:node|pool|dataset|lun|share|site):[A-Za-z0-9._/-]{1,160}\z} ? 1 : 0;
}

sub allows {
    my ($self, %args) = @_;
    my $grants = $args{grants};
    my $required = $args{required_scope};

    return {
        allowed => 0,
        reason => 'invalid_required_scope',
    } unless $self->valid_scope($required);

    return {
        allowed => 0,
        reason => 'missing_scope_grants',
    } unless ref($grants) eq 'ARRAY';

    for my $g (@$grants) {
        next unless $self->valid_scope($g);
        return {
            allowed => 1,
            reason => 'scope_exact_match',
            required_scope => $required,
        } if $g eq $required;
    }

    return {
        allowed => 0,
        reason => 'scope_denied',
        required_scope => $required,
    };
}

1;
