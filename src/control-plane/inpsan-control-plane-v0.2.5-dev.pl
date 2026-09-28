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
use INPSan::Security::Scope;
use INPSan::Security::Certificate;

# INPSan Control Plane v0.2.5-dev
# Security milestone: SEC-IMP-04 TLS / session / certificate foundation.
#
# Development constraints:
# - loopback only;
# - TLS is mandatory in this build;
# - current evaluation binding remains loopback-only until production exposure is separately accepted;
# - no storage state-changing endpoint exists in this build.
#
# Related evidence:
# docs/11-security/CONTROL_PLANE_SECURITY_CONTRACT_V1.md
# docs/11-security/SFR_TRACEABILITY_BASELINE_V0.1.md

my $port = 18443;
my $help = 0;
my $user_store = $ENV{INPSAN_CP_USER_STORE} || '/var/opt/inpsan/security/users.json';
my $audit_log = $ENV{INPSAN_CP_AUTH_AUDIT} || '/var/tmp/inpsan-control-plane-auth-audit.jsonl';
my $tls_cert = $ENV{INPSAN_CP_TLS_CERT};
my $tls_key = $ENV{INPSAN_CP_TLS_KEY};
my $idle_timeout = 900;
my $absolute_timeout = 28800;

GetOptions(
    'port=i'       => \$port,
    'user-store=s' => \$user_store,
    'audit-log=s'        => \$audit_log,
    'tls-cert=s'          => \$tls_cert,
    'tls-key=s'           => \$tls_key,
    'idle-timeout=i'      => \$idle_timeout,
    'absolute-timeout=i'  => \$absolute_timeout,
    'help'                => \$help,
) or die "invalid arguments\n";

if ($help) {
    print "Usage: $0 --tls-cert CERT --tls-key KEY [--port 18443] [--user-store PATH] [--audit-log PATH]\n";
    print "TLS-only loopback development/evaluation build.\n";
    exit 0;
}

die "invalid port\n" if $port < 1024 || $port > 65535;
die "invalid idle timeout\n" if $idle_timeout < 1 || $idle_timeout > 86400;
die "invalid absolute timeout\n" if $absolute_timeout < 2 || $absolute_timeout > 604800;
die "absolute timeout must exceed idle timeout\n" if $absolute_timeout <= $idle_timeout;
die "TLS certificate required\n" unless defined($tls_cert) && -f $tls_cert;
die "TLS private key required\n" unless defined($tls_key) && -f $tls_key;

eval { require IO::Socket::SSL; 1 }
    or die "IO::Socket::SSL is required for TLS mode\n";

my $auth = INPSan::Security::Auth->new(
    user_store => $user_store,
    idle_timeout => $idle_timeout,
    absolute_timeout => $absolute_timeout,
);
my $rbac = INPSan::Security::RBAC->new();
my $endpoint_policy = INPSan::Security::EndpointPolicy->new();
my $scope_engine = INPSan::Security::Scope->new();
my $certificate = INPSan::Security::Certificate->new(
    cert_path => $tls_cert,
    key_path => $tls_key,
);
my $certificate_health = $certificate->health();
die "TLS certificate/key health check failed\n" unless $certificate_health->{ok};

my $audit = INPSan::Security::Audit->new(
    path => $audit_log,
    product_version => '0.2.5-dev',
    source => 'control-plane',
    max_file_bytes => 2 * 1024 * 1024,
    max_archives => 5,
);

my %fail_state;
$SIG{PIPE} = 'IGNORE';

my $audit_reconcile = $audit->reconcile_state();
die "audit reconciliation failed\n" unless $audit_reconcile->{ok};

my $server = IO::Socket::SSL->new(
    LocalAddr => '127.0.0.1',
    LocalPort => $port,
    Proto => 'tcp',
    Listen => 10,
    ReuseAddr => 1,
    SSL_server => 1,
    SSL_cert_file => $tls_cert,
    SSL_key_file => $tls_key,
    SSL_version => 'SSLv23:!TLSv1:!TLSv1_1:!SSLv3:!SSLv2',
    SSL_verify_mode => 0,
) or die "cannot bind TLS 127.0.0.1:$port: " . IO::Socket::SSL::errstr() . "\n";

print "INPSan Control Plane v0.2.5-dev TLS listening on 127.0.0.1:$port\n";
print "AUTHENTICATED TLS DEVELOPMENT/EVALUATION PROTOTYPE — loopback only\n";

while (1) {
    my $client = $server->accept();
    if (!$client) {
        warn "TLS accept rejected connection: " . IO::Socket::SSL::errstr() . "\n";
        next;
    }

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
        my $sid = $session->{session_id};
        $auth->revoke_session($token);
        $audit->write_event(actor_id=>$session->{username}, actor_type=>'user', session_id=>$sid, action=>'logout', target_type=>'session', target_id=>$sid, outcome=>'success', reason=>'user_logout');
        return (
            200,
            ok_obj({ logged_out => JSON::PP::true }, 'fresh', 'auth-v0.3'),
            { 'Set-Cookie' => expired_session_cookie() }
        );
    }

    if ($req->{path} eq '/api/v1/audit/query') {
        return audit_query_route($req, $session);
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
            session_id => $session->{session_id},
        }, 'fresh', 'auth-v0.2'));
    }

    return (405, error_obj('method_not_allowed', 'Only GET is supported for this endpoint.'))
        unless $req->{method} eq 'GET';

    if ($req->{path} eq '/api/v1/product/version') {
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        return (200, ok_obj(product_version(), 'fresh', 'control-plane-dev'));
    }

    if ($req->{path} eq '/api/v1/audit/health') {
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        return (200, ok_obj($audit->health(), 'fresh', 'audit-v0.3'));
    }

    if ($req->{path} eq '/api/v1/audit/verify') {
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        my $v = $audit->verify_chain();
        return ($v->{ok} ? 200 : 503, ok_obj($v, 'fresh', 'audit-v0.3'));
    }

    if ($req->{path} eq '/api/v1/security/tls') {
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        return (200, ok_obj($certificate->health(), 'fresh', 'certificate-v0.1'));
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

    if ($req->{path} =~ m{\A/api/v1/storage/pools/([A-Za-z0-9._-]{1,128})\z}) {
        my $pool = $1;
        my $az = authorize_endpoint($session, $req->{method}, $req->{path});
        return @$az unless $az->[0] == 0;
        my ($data, $freshness, $http_status) = storage_pool_detail($pool);
        return ($http_status, ok_obj($data, $freshness, 'zpool-list-detail'));
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
            session_id=>$session->{session_id},
            action=>'authorization',
            target_type=>'endpoint',
            target_id=>$path,
            outcome=>'deny',
            reason=>'endpoint_policy_missing'
        );
        return [403, error_obj('forbidden', 'Endpoint policy missing.')];
    }

    my $scope_allowed;
    if ($policy->{scope_required}) {
        my $scope_decision = $scope_engine->allows(
            grants => $session->{scopes},
            required_scope => $policy->{required_scope},
        );
        if (!$scope_decision->{allowed}) {
            $audit->write_event(
                actor_id=>$session->{username},
                actor_type=>'user',
                session_id=>$session->{session_id},
                action=>'authorization',
                target_type=>$policy->{resource_type} || 'resource',
                target_id=>$policy->{resource_id} || $path,
                permission=>$policy->{permission},
                outcome=>'deny',
                reason=>$scope_decision->{reason}
            );
            return [403, error_obj('forbidden', 'Resource scope denied.')];
        }
        $scope_allowed = 1;
    }

    my $decision = $rbac->authorize(
        roles => $session->{roles},
        required_capability => $policy->{permission},
        scope_required => $policy->{scope_required} ? 1 : 0,
        ($policy->{scope_required} ? (scope_allowed => $scope_allowed) : ()),
    );

    if (!$decision->{allowed}) {
        $audit->write_event(
            actor_id=>$session->{username},
            actor_type=>'user',
            session_id=>$session->{session_id},
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

sub audit_query_route {
    my ($req, $session) = @_;
    return (405, error_obj('method_not_allowed', 'POST required.')) unless $req->{method} eq 'POST';

    my $az = authorize_endpoint($session, $req->{method}, $req->{path});
    return @$az unless $az->[0] == 0;

    return (415, error_obj('unsupported_media_type', 'application/json required.'))
        unless (($req->{headers}{'content-type'} || '') =~ m{^application/json(?:\s*;|\z)}i);

    my $obj = {};
    if (length($req->{body})) {
        return (400, error_obj('invalid_json', 'Invalid JSON body.'))
            unless eval { $obj = decode_json($req->{body}); 1 } && ref($obj) eq 'HASH';
    }

    my %q;
    for my $k (qw(actor_id action outcome target_type)) {
        next unless defined($obj->{$k});
        return (400, error_obj('invalid_filter', 'Invalid audit filter.'))
            unless $obj->{$k} =~ /\A[A-Za-z0-9._:\/-]{1,160}\z/;
        $q{$k} = $obj->{$k};
    }
    if (defined($obj->{limit})) {
        return (400, error_obj('invalid_limit', 'Invalid audit limit.'))
            unless $obj->{limit} =~ /^\d+$/ && $obj->{limit} >= 1 && $obj->{limit} <= 1000;
        $q{limit} = 0 + $obj->{limit};
    }

    my $events = $audit->query_events(%q);
    $audit->write_event(
        actor_id=>$session->{username},
        actor_type=>'user',
        session_id=>$session->{session_id},
        action=>'audit_query',
        target_type=>'audit',
        target_id=>'security-audit',
        permission=>'audit.read',
        outcome=>'success',
        reason=>'authorized_query',
        event_class=>'security_critical'
    );

    return (200, ok_obj({ count => scalar(@$events), events => $events }, 'fresh', 'audit-v0.3'));
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
    my ($session_ok, $session) = $auth->validate_session($token);
    die "session issuance validation failed\n" unless $session_ok;

    $audit->write_event(
        actor_id=>$username,
        actor_type=>'user',
        session_id=>$session->{session_id},
        action=>'login',
        target_type=>'session',
        target_id=>$session->{session_id},
        outcome=>'success',
        reason=>'authenticated'
    );

    return (
        200,
        ok_obj({
            authenticated => JSON::PP::true,
            session_id => $session->{session_id},
            idle_timeout_seconds => 0 + $idle_timeout,
            absolute_timeout_seconds => 0 + $absolute_timeout,
            user => {
                user_id => $user->{user_id},
                username => $user->{username},
                roles => $user->{roles},
                scopes => $user->{scopes} || ['node:local'],
            },
        }, 'fresh', 'auth-v0.3'),
        { 'Set-Cookie' => session_cookie($token, $absolute_timeout) }
    );
}

sub require_session {
    my ($req) = @_;
    my $token;

    my $hdr = $req->{headers}{authorization} || '';
    if ($hdr =~ /^Bearer\s+([A-Za-z0-9_-]{32,})\z/) {
        $token = $1;
    } else {
        my $cookie = $req->{headers}{cookie} || '';
        if ($cookie =~ /(?:^|;\s*)__Host-INPSAN_SESSION=([A-Za-z0-9_-]{32,})(?:;|\z)/) {
            $token = $1;
        }
    }

    return (0, undef, undef, 'missing_authorization') unless defined($token);
    my ($ok, $session, $reason) = $auth->validate_session($token);
    return ($ok, $session, $token, $reason);
}

sub session_cookie {
    my ($token, $max_age) = @_;
    return '__Host-INPSAN_SESSION=' . $token
        . '; Path=/; Max-Age=' . (0 + $max_age)
        . '; Secure; HttpOnly; SameSite=Strict';
}

sub expired_session_cookie {
    return '__Host-INPSAN_SESSION=; Path=/; Max-Age=0; Secure; HttpOnly; SameSite=Strict';
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
    print $client "Strict-Transport-Security: max-age=31536000\r\n";
    print $client "Content-Security-Policy: default-src 'none'; frame-ancestors 'none'; base-uri 'none'\r\n";
    print $client "Permissions-Policy: camera=(), microphone=(), geolocation=()\r\n";
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
    return { control_plane => '0.2.5-dev', security_milestone => 'SEC-IMP-04-TLS+SESSION+CERT', components => \@out };
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

sub storage_pool_detail {
    my ($pool) = @_;
    return ({ error => 'invalid_pool_name' }, 'invalid', 400)
        unless defined($pool) && $pool =~ /\A[A-Za-z0-9._-]{1,128}\z/;

    my ($out, $rc) = run_capture('/usr/sbin/zpool', 'list', '-Hp', $pool);
    return ({ pool => undef, found => JSON::PP::false }, 'fresh', 404)
        unless defined($out) && $rc == 0;

    my ($line) = grep { length($_) } split /\n/, $out;
    return ({ pool => undef, found => JSON::PP::false }, 'fresh', 404)
        unless defined($line);

    my @f = split /\t|\s+/, $line;
    return ({ source_unavailable => JSON::PP::true }, 'source_unavailable', 503)
        unless @f >= 10;

    return ({
        found => JSON::PP::true,
        pool => {
            name => $f[0],
            size_bytes => 0 + $f[1],
            allocated_bytes => 0 + $f[2],
            free_bytes => 0 + $f[3],
            capacity_percent => ($f[7] =~ /^\d+$/ ? 0 + $f[7] : undef),
            health => $f[9],
        },
    }, 'fresh', 200);
}

sub trim_one_line {
    my ($s) = @_;
    $s =~ s/\r?\n+/ /g;
    $s =~ s/\s+/ /g;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}
