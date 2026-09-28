#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use JSON::PP qw(encode_json decode_json);
use Getopt::Long qw(GetOptions);
use POSIX qw(strftime);

# INPSan Control Plane v0.1.0-dev
# Development-only, read-only, loopback-bound prototype.
# Security contract: docs/11-security/CONTROL_PLANE_SECURITY_CONTRACT_V1.md
# API contract: docs/01-architecture/CONTROL_PLANE_API_V0_1.md

my $port = 18080;
my $help = 0;
GetOptions(
    'port=i' => \$port,
    'help'   => \$help,
) or die "invalid arguments\n";

if ($help) {
    print "Usage: $0 [--port 18080]\n";
    print "Binds to 127.0.0.1 only. Development/read-only prototype.\n";
    exit 0;
}

die "invalid port\n" if $port < 1024 || $port > 65535;

my $server = IO::Socket::INET->new(
    LocalAddr => '127.0.0.1',
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 10,
    ReuseAddr => 1,
) or die "cannot bind 127.0.0.1:$port: $!\n";

print "INPSan Control Plane v0.1.0-dev listening on 127.0.0.1:$port\n";
print "READ-ONLY DEVELOPMENT PROTOTYPE — no production authentication yet\n";

while (my $client = $server->accept()) {
    $client->autoflush(1);
    my $request = <$client>;
    if (!defined $request || length($request) > 8192) {
        respond($client, 400, error_obj('bad_request', 'Invalid request.'));
        close $client;
        next;
    }

    my ($method, $target, $httpver) = split /\s+/, $request;
    while (my $h = <$client>) {
        last if $h =~ /^\r?\n$/;
        last if tell_guard($h);
    }

    if (!defined $method || !defined $target || $method ne 'GET') {
        respond($client, 405, error_obj('method_not_allowed', 'Only GET is supported in v0.1.'));
        close $client;
        next;
    }

    my ($path, $query) = split /\?/, $target, 2;
    if (defined $query && length $query) {
        respond($client, 400, error_obj('unsupported_query', 'Query parameters are not enabled in this prototype build.'));
        close $client;
        next;
    }

    my ($code, $obj) = route($path);
    respond($client, $code, $obj);
    close $client;
}

sub tell_guard {
    my ($line) = @_;
    return length($line) > 16384 ? 1 : 0;
}

sub route {
    my ($path) = @_;

    return (200, ok_obj(product_version(), 'fresh', 'control-plane-dev'))
        if $path eq '/api/v1/product/version';

    if ($path eq '/api/v1/system/health') {
        my ($data, $freshness, $http_status) = system_health();
        return ($http_status, ok_obj($data, $freshness, 'local-read-model'));
    }

    if ($path eq '/api/v1/storage/pools') {
        my ($data, $freshness, $http_status) = storage_pools();
        return ($http_status, ok_obj($data, $freshness, 'zpool-list'));
    }

    return (501, error_obj('not_implemented', 'Endpoint is defined by the contract but not implemented in this dev build.'))
        if $path =~ m{^/api/v1/(?:storage/disks|hardware/topology|performance/live|alerts|events)$};

    return (404, error_obj('not_found', 'Unknown endpoint.'));
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
        meta => {
            source_version => $source_version,
            freshness => $freshness,
        },
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
    my ($client, $status, $obj) = @_;
    my %reason = (
        200 => 'OK',
        400 => 'Bad Request',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        503 => 'Service Unavailable',
    );
    my $json = encode_json($obj);
    my $r = $reason{$status} || 'Error';
    print $client "HTTP/1.1 $status $r\r\n";
    print $client "Content-Type: application/json; charset=utf-8\r\n";
    print $client "Cache-Control: no-store\r\n";
    print $client "X-Content-Type-Options: nosniff\r\n";
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
    return { control_plane => '0.1.0-dev', components => \@out };
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
            } else {
                $alert = { parse_error => JSON::PP::true };
            }
        } else {
            $alert = { source_unavailable => JSON::PP::true };
        }
    } else {
        $alert = { source_unavailable => JSON::PP::true };
    }

    my $freshness = ($zpool_available && $alert_available) ? 'fresh'
                  : ($zpool_available || $alert_available) ? 'stale'
                  : 'source_unavailable';
    my $http_status = ($zpool_available || $alert_available) ? 200 : 503;

    return ({
        pools_healthy => $pools_healthy,
        zpool_status_summary => $zpool_available ? trim_one_line($zout) : undef,
        zpool_source_available => $zpool_available ? JSON::PP::true : JSON::PP::false,
        alert_source_available => $alert_available ? JSON::PP::true : JSON::PP::false,
        alert_engine => $alert,
    }, $freshness, $http_status);
}

sub storage_pools {
    my ($out, $rc) = run_capture('/usr/sbin/zpool', 'list', '-Hp');
    return ({
        source_unavailable => JSON::PP::true,
        pools => []
    }, 'source_unavailable', 503) unless defined($out) && $rc == 0;

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