package INPSan::Security::EndpointPolicy;

use strict;
use warnings;

our $VERSION = '0.1.0-dev';

# Purpose:
#   Central registry for endpoint -> permission mapping.
#
# Security intent:
#   Avoid scattered authorization literals and make the management attack
#   surface auditable, testable and exportable for AFTA/Common Criteria evidence.
#
# Rules:
#   - deny by default;
#   - every protected route must be explicitly registered;
#   - method and permission are part of the policy contract;
#   - object/scope rules can be attached without changing route code.

my %POLICY = (
    'GET /api/v1/product/version' => {
        permission => 'system.read',
        scope_required => 0,
    },
    'GET /api/v1/system/health' => {
        permission => 'health.read',
        scope_required => 0,
    },
    'GET /api/v1/storage/pools' => {
        permission => 'storage.read',
        scope_required => 0,
    },
    'GET /api/v1/auth/me' => {
        permission => 'system.read',
        scope_required => 0,
    },
    'POST /api/v1/auth/logout' => {
        permission => 'system.read',
        scope_required => 0,
    },
);

sub new { return bless {}, $_[0]; }

sub lookup {
    my ($self, $method, $path) = @_;
    return undef unless defined($method) && defined($path);
    my $k = uc($method) . ' ' . $path;
    my $p = $POLICY{$k};
    return undef unless $p;
    return { %$p };
}

sub registered_routes {
    return [ sort keys %POLICY ];
}

1;
