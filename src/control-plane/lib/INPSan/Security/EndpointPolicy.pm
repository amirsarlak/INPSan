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
    'GET /api/v1/audit/health' => {
        permission => 'audit.read',
        scope_required => 0,
    },
    'GET /api/v1/audit/verify' => {
        permission => 'audit.read',
        scope_required => 0,
    },
    'POST /api/v1/audit/query' => {
        permission => 'audit.read',
        scope_required => 0,
    },
    'GET /api/v1/security/tls' => {
        permission => 'security.read',
        scope_required => 0,
    },
);

sub new { return bless {}, $_[0]; }

sub lookup {
    my ($self, $method, $path) = @_;
    return undef unless defined($method) && defined($path);

    my $k = uc($method) . ' ' . $path;
    if (my $p = $POLICY{$k}) {
        return { %$p };
    }

    if (uc($method) eq 'GET' && $path =~ m{\A/api/v1/storage/pools/([A-Za-z0-9._-]{1,128})\z}) {
        my $pool = $1;
        return {
            permission => 'storage.read',
            scope_required => 1,
            required_scope => 'pool:' . $pool,
            resource_type => 'pool',
            resource_id => $pool,
        };
    }

    return undef;
}

sub registered_routes {
    return [ sort keys %POLICY ];
}

1;
