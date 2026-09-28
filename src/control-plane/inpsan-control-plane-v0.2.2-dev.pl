#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use IO::Socket::INET;
use JSON::PP qw(encode_json decode_json);
use Getopt::Long qw(GetOptions);
use POSIX qw(strftime);
use Fcntl qw(:DEFAULT :flock);
use INPSan::Security::Auth;
use INPSan::Security::RBAC;
use INPSan::Security::EndpointPolicy;
use INPSan::Security::Audit;

# INPSan Control Plane v0.2.2-dev
# Security milestone: SEC-IMP-01 independent identity/authentication foundation.
#
# Development constraints:
# - loopback only;
# - HTTP only because TLS work is SEC-IMP-05 and is NOT complete;
# - therefore this build MUST NOT be exposed to a management network;
# - no storage state-changing endpoint exists in this build.
#
# Related evidence:
# docs/11-security/CONTROL_PLANE_SECURITY_CONTRACT_V1.md
# docs/11-security/SFR_TRACEABILITY_BASELINE_V0.1.md

my $port = 18080;
my $help = 0;
my $user_store = $ENV{INPSAN_CP_USER_STORE} || '/var/opt/inpsan/security/users.json';
my $audit_log = $ENV{INPSAN_CP_AUTH_AUDIT} || '/var/tmp/inpsan-control-plane-auth-audit.jsonl';

GetOptions(
    'port=i'       => \$port,
    'user-store=s' => \$user_store,
    'audit-log=s'  => \$audit_log,
    'help'         => \$help,
) or die "invalid arguments\n";

if ($help) {
    print "Usage: $0 [--port 18080] [--user-store PATH] [--audit-log PATH]\n";
    print "Loopback-only development build. TLS is not implemented yet.\n";
    exit 0;
}

die "invalid port\n" if $port < 1024 || $port > 65535;

my $auth = INPSan::Security::Auth->new(
    user_store => $user_store,
    idle_timeout => 900,
    absolute_timeout => 28800,
);
my $rbac = INPSan::Security::RBAC->new();
my $endpoint_policy = INPSan::Security::EndpointPolicy->new();
my $audit = INPSan::Security::Audit->new(
    path => $audit_log,
    product_version => '0.2.2-dev',
    source => 'control-plane',
);

my %fail_state;

my $server = IO::Socket::INET->new(
    LocalAddr => '127.0.0.1',
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 10,
    ReuseAddr => 1,
) or die "cannot bind 127.0.0.1:$port: $!\n";

print "INPSan Control Plane v0.2.2-dev listening on 127.0.0.1:$port\n";
print "AUTHENTICATED DEVELOPMENT PROTOTYPE — loopback only; TLS pending\n";

while (my $client = $server->accept()) {
    $client->autoflush(1);

    my ($request, $err) = read_request($client);
    if (!$request) {
        respond($client, 400, error_obj('bad_request', $err || 'Invalid request.'));
        close $client;
        next;
    }

    my ($code, $obj, $extra_headers) = dispatch($request);
    respond($client, $code, $obj, $extra_headers);
    close $client;
}

sub read_request {
    my ($client) = @_;
    my $line = <$client>;
    return (undef, 'missing request line') unless defined $line;
    return (undef, 'request line too large') if length($line) > 8192;

    $line =~ s/\r?\n\z//;
    my ($method, $target, $httpver) = split /\s+/, $line;
    return (undef, 'invalid request line') unless $method && $target && $httpver =~ m{^HTTP/1\.[01]$};

    my %headers;
    my $header_bytes = 0;
    while (my $h = <$client>) {
        $header_bytes += length($h);
        return (undef, 'headers too large') if $header_bytes > 16384;
        last if $h =~ /^\r?\n$/;
        $h =~ s/\r?\n\z//;
        my ($name, $value) = split /:\s*/, $h, 2;
        return (undef, 'invalid header') unless defined($name) && defined($value);
        $headers{lc($name)} = $value;
    }

    my $content_length = $headers{'content-length'} || 0;
    return (undef, 'invalid content length') unless $content_length =~ /^\d+$/ && $content_length <= 16384;

    my $body = '';
    if ($content_length > 0) {
        my $read = read($client, $body, $content_length);
        return (undef, 'short request body') unless defined($read) && $read == $content_length;
    }

    my ($path, $query) = split /\?/, $target, 2;
    return (undef, 'query parameters are not enabled') if defined($query) && length($query);

    return ({
        method => $method,
        path => $path,
        headers => \%headers,
        body => $body,
    }, undef);
}

sub dispatch {
    my ($req) = @_;

    if ($req->{path} eq '/api/v1/auth/login') {
        return login_route($req);
    }

    my ($session_ok, $session, $token, $reason) = require_session($req);
    if (!$session_ok) {
        $audit->write_event(actor_id=>'anonymous', actor_type=>'unknown', action=>'authentication', target_type=>'endpoint', target_id=>$req->{path}, outcome=>'deny', reason=>$reason);
        return (401, error_obj('unauthorized', 'Authentication required.'), {'WWW-Authenticate' => 'Bearer'});
    }

    if ($req->{path} eq '/api/v1/auth/logout') {
        return (405, error_obj('method_not_allowed', 'POST required.')) unless $req->{method} eq 'POST';
        $auth->revoke_session($token);
        $audit->write_event(actor_id=>$session->{username}, actor_type=>'user', action=>'logout', target_type=>'session', target_id=>'self', outcome=>'success', reason=>'user_logout');
        return (200, ok_obj({ logged_out => JSON::PP::true }, 'fresh', 'auth-v0.2'));
    }

    if ($req->{path} eq '/api/v1/auth/me') {
        return (405, error_obj('method_not_allowed', 'GET required.')) unless $req->{method} eq 'GET';
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        return (200, ok_obj({
            user_id => $session->{user_id},
            username => $session->{username},
            roles => $session->{roles},
            scopes => $session->{scopes},
        }, 'fresh', 'auth-v0.2'));
    }

    return (405, error_obj('method_not_allowed', 'Only GET is supported for this endpoint.'))
        unless $req->{method} eq 'GET';

    if ($req->{path} eq '/api/v1/product/version') {
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        return (200, ok_obj(product_version(), 'fresh', 'control-plane-dev'));
    }

    if ($req->{path} eq '/api/v1/system/health') {
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        my ($data, $freshness, $http_status) = system_health();
        return ($http_status, ok_obj($data, $freshness, 'local-read-model'));
    }

    if ($req->{path} eq '/api/v1/storage/pools') {
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        my ($data, $freshness, $http_status) = storage_pools();
        return ($http_status, ok_obj($data, $freshness, 'zpool-list'));
    }

    return (501, error_obj('not_implemented', 'Endpoint is defined by the contract but not implemented in this dev build.'))
        if $req->{path} =~ m{^/api/v1/(?:storage/disks|hardware/topology|performance/live|alerts|events)$};

    return (404, error_obj('not_found', 'Unknown endpoint.'));
}

sub authorize_endpoint {
    my ($session, $method, $path) = @_;
    my $policy = $endpoint_policy->lookup($method, $path);

    if (!$policy) {
        $audit->write_event(
            actor_id=>$session->{username},
            actor_type=>'user',
            action=>'authorization',
            target_type=>'endpoint',
            target_id=>$path,
            outcome=>'deny',
            reason=>'endpoint_policy_missing'
        );
        return [403, error_obj('forbidden', 'Endpoint policy missing.')];
    }

    my $decision = $rbac->authorize(
        roles => $session->{roles},
        required_capability => $policy->{permission},
        scope_required => $policy->{scope_required} ? 1 : 0,
    );

    if (!$decision->{allowed}) {
        $audit->write_event(
            actor_id=>$session->{username},
            actor_type=>'user',
            action=>'authorization',
            target_type=>'endpoint',
            target_id=>$path,
            permission=>$policy->{permission},
            outcome=>'deny',
            reason=>$decision->{reason}
        );
        return [403, error_obj('forbidden', 'Insufficient permission.')];
    }

    return [0];
}

sub login_route {
    my ($req) = @_;
    return (405, error_obj('method_not_allowed', 'POST required.')) unless $req->{method} eq 'POST';
    return (415, error_obj('unsupported_media_type', 'application/json required.'))
        unless (($req->{headers}{'content-type'} || '') =~ m{^application/json(?:\s*;|\z)}i);

    my $obj;
    if (!eval { $obj = decode_json($req->{body}); 1 } || ref($obj) ne 'HASH') {
        $audit->write_event(actor_id=>'unknown', actor_type=>'unknown', action=>'login', target_type=>'session', target_id=>'new', outcome=>'deny', reason=>'invalid_json');
        return (400, error_obj('invalid_json', 'Invalid JSON body.'));
    }

    my $username = $obj->{username};
    my $password = $obj->{password};
    if (!defined($username) || !defined($password) || length($username) > 64 || length($password) > 1024) {
        $audit->write_event(actor_id=>'unknown', actor_type=>'unknown', action=>'login', target_type=>'session', target_id=>'new', outcome=>'deny', reason=>'invalid_login_shape');
        return (400, error_obj('invalid_login', 'Invalid login request.'));
    }

    if (is_rate_limited($username)) {
        $audit->write_event(actor_id=>$username, actor_type=>'user', action=>'login', target_type=>'session', target_id=>'new', outcome=>'deny', reason=>'rate_limited');
        return (429, error_obj('rate_limited', 'Too many failed authentication attempts.'));
    }

    my ($ok, $user, $reason) = $auth->authenticate($username, $password);
    $password = undef;
    $obj->{password} = undef;

    if (!$ok) {
        record_failure($username);
        $audit->write_event(actor_id=>$username, actor_type=>'user', action=>'login', target_type=>'session', target_id=>'new', outcome=>'deny', reason=>$reason);
        return (401, error_obj('invalid_credentials', 'Invalid username or password.'), {'WWW-Authenticate' => 'Bearer'});
    }

    clear_failures($username);
    my $token = $auth->issue_session($user);
    $audit->write_event(actor_id=>$username, actor_type=>'user', action=>'login', target_type=>'session', target_id=>'new', outcome=>'success', reason=>'authenticated');

    return (200, ok_obj({
        access_token => $token,
        token_type => 'Bearer',
        expires_in => 28800,
        user => {
            user_id => $user->{user_id},
            username => $user->{username},
            roles => $user->{roles},
        },
    }, 'fresh', 'auth-v0.2'));
}

sub require_session {
    my ($req) = @_;
    my $hdr = $req->{headers}{authorization} || '';
    return (0, undef, undef, 'missing_authorization') unless $hdr =~ /^Bearer\s+([A-Za-z0-9_-]{32,})\z/;
    my $token = $1;
    my ($ok, $session, $reason) = $auth->validate_session($token);
    return ($ok, $session, $token, $reason);
}

sub is_rate_limited {
    my ($username) = @_;
    my $key = lc($username || '');
    my $s = $fail_state{$key};
    return 0 unless $s;
    return 0 if time() - $s->{window_start} > 60;
    return ($s->{count} >= 5) ? 1 : 0;
}

sub record_failure {
    my ($username) = @_;
    my $key = lc($username || '');
    my $now = time();
    my $s = $fail_state{$key};
    if (!$s || $now - $s->{window_start} > 60) {
        $fail_state{$key} = { count => 1, window_start => $now };
    } else {
        $s->{count}++;
    }
}

sub clear_failures {
    my ($username) = @_;
    delete $fail_state{lc($username || '')};
}

sub now_rfc3339 {
    return strftime('%Y-%m-%dT%H:%M:%SZ', gmtime());
}

sub ok_obj {
    my ($data, $freshness, $source_version) = @_;
    return {
        ok => JSON::PP::true,
        schema_version => '1.0',
        generated_at => now_rfc3339(),
        data => $data,
        meta => { source_version => $source_version, freshness => $freshness },
    };
}

sub error_obj {
    my ($code, $message) = @_;
    return {
        ok => JSON::PP::false,
        schema_version => '1.0',
        error => { code => $code, message => $message },
    };
}

sub respond {
    my ($client, $status, $obj, $extra) = @_;
    my %reason = (
        200 => 'OK', 400 => 'Bad Request', 401 => 'Unauthorized', 403 => 'Forbidden',
        404 => 'Not Found', 405 => 'Method Not Allowed',
        415 => 'Unsupported Media Type', 429 => 'Too Many Requests',
        500 => 'Internal Server Error', 501 => 'Not Implemented',
        503 => 'Service Unavailable',
    );
    my $json = encode_json($obj);
    my $r = $reason{$status} || 'Error';
    print $client "HTTP/1.1 $status $r\r\n";
    print $client "Content-Type: application/json; charset=utf-8\r\n";
    print $client "Cache-Control: no-store\r\n";
    print $client "Pragma: no-cache\r\n";
    print $client "X-Content-Type-Options: nosniff\r\n";
    print $client "X-Frame-Options: DENY\r\n";
    print $client "Referrer-Policy: no-referrer\r\n";
    if ($extra && ref($extra) eq 'HASH') {
        for my $k (sort keys %$extra) {
            next unless $k =~ /\A[A-Za-z0-9-]+\z/;
            my $v = $extra->{$k};
            next if !defined($v) || $v =~ /[\r\n]/;
            print $client "$k: $v\r\n";
        }
    }
    print $client "Connection: close\r\n";
    print $client "Content-Length: " . length($json) . "\r\n\r\n";
    print $client $json;
}

sub read_trimmed {
    my ($path) = @_;
    return undef unless -f $path;
    open my $fh, '<', $path or return undef;
    local $/;
    my $v = <$fh>;
    close $fh;
    return undef unless defined $v;
    $v =~ s/^\s+|\s+$//g;
    return $v;
}

sub run_capture {
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

sub product_version {
    my @components = (
        ['dashboard', '/opt/inpsan/dashboard/VERSION', '/opt/inpsan/dashboard/BUILD'],
        ['alert_engine', '/opt/inpsan/alert-engine/VERSION', '/opt/inpsan/alert-engine/BUILD'],
        ['hardware_topology', '/opt/inpsan/hardware-topology-telemetry/VERSION', undef],
        ['io_telemetry', '/opt/inpsan/io-telemetry/VERSION', undef],
        ['notification_engine', undef, '/opt/inpsan/notification-engine/BUILD'],
        ['notification_center', undef, '/opt/inpsan/notification-center/BUILD'],
    );
    my @out;
    for my $c (@components) {
        my ($name, $vpath, $bpath) = @$c;
        push @out, {
            component => $name,
            version => defined($vpath) ? read_trimmed($vpath) : undef,
            build => defined($bpath) ? read_trimmed($bpath) : undef,
        };
    }
    return { control_plane => '0.2.2-dev', security_milestone => 'SEC-IMP-02+SEC-IMP-03', components => \@out };
}

sub system_health {
    my ($zout, $zrc) = run_capture('/usr/sbin/zpool', 'status', '-x');
    my $zpool_available = defined($zout) && $zrc == 0;
    my $pools_healthy = $zpool_available && $zout =~ /all pools are healthy/i ? JSON::PP::true : JSON::PP::false;

    my $alert_path = '/opt/inpsan/alert-engine/bin/inpsan-alertctl';
    my $alert;
    my $alert_available = 0;
    if (-x $alert_path) {
        my ($aout, $arc) = run_capture($alert_path, 'status');
        if (defined $aout && $arc == 0) {
            if (eval { $alert = decode_json($aout); 1 }) {
                $alert_available = 1;
            } else { $alert = { parse_error => JSON::PP::true }; }
        } else { $alert = { source_unavailable => JSON::PP::true }; }
    } else { $alert = { source_unavailable => JSON::PP::true }; }

    my $freshness = ($zpool_available && $alert_available) ? 'fresh'
                  : ($zpool_available || $alert_available) ? 'stale'
                  : 'source_unavailable';

    return ({
        pools_healthy => $pools_healthy,
        zpool_status_summary => $zpool_available ? trim_one_line($zout) : undef,
        zpool_source_available => $zpool_available ? JSON::PP::true : JSON::PP::false,
        alert_source_available => $alert_available ? JSON::PP::true : JSON::PP::false,
        alert_engine => $alert,
    }, $freshness, 200);
}

sub storage_pools {
    my ($out, $rc) = run_capture('/usr/sbin/zpool', 'list', '-Hp');
    return ({ source_unavailable => JSON::PP::true, pools => [] }, 'source_unavailable', 200)
        unless defined($out) && $rc == 0;

    my @pools;
    for my $line (split /\n/, $out) {
        next unless length $line;
        my @f = split /\t|\s+/, $line;
        next unless @f >= 10;
        push @pools, {
            name => $f[0],
            size_bytes => 0 + $f[1],
            allocated_bytes => 0 + $f[2],
            free_bytes => 0 + $f[3],
            capacity_percent => ($f[7] =~ /^\d+$/ ? 0 + $f[7] : undef),
            health => $f[9],
        };
    }
    return ({ pools => \@pools, count => scalar(@pools) }, 'fresh', 200);
}

sub trim_one_line {
    my ($s) = @_;
    $s =~ s/\r?\n+/ /g;
    $s =~ s/\s+/ /g;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}
