#!/usr/bin/bash
# INPSan 3.3 Benchmark Collector — development candidate
# Purpose: capture a reproducible, non-destructive resource/performance evidence set.
# Safety: does not change storage/service/network configuration; writes evidence files only.
# Related: CP-KB-001 / WP-3.3-001 / PERFORMANCE_BENCHMARK_SPEC.md

set -u

STAMP=$(date '+%Y%m%d-%H%M%S')
OUT=${1:-/var/tmp/inpsan-benchmark-${STAMP}}
mkdir -p "$OUT" || exit 1

run_capture() {
  name=$1
  shift
  {
    echo "# captured_at=$(date '+%Y-%m-%dT%H:%M:%S%z')"
    echo "# command=$*"
    "$@"
  } >"$OUT/$name" 2>&1
}

{
  echo "benchmark_version=0.1.0-dev"
  echo "captured_at=$(date '+%Y-%m-%dT%H:%M:%S%z')"
  echo "hostname=$(uname -n 2>/dev/null || echo unknown)"
  echo "output_directory=$OUT"
} >"$OUT/manifest.txt"

{
  date
  uname -a
  uptime
  echo
  pkg info entire 2>&1
} >"$OUT/host.txt"

{
  svcs -a 2>&1 | grep inpsan || true
} >"$OUT/services.txt"

{
  ps -ef 2>&1 | grep '[i]npsan' || true
} >"$OUT/processes.txt"

run_capture vmstat.txt vmstat 1 5
run_capture mpstat.txt mpstat 1 5

{
  echo '# ZFS ARC selected kstats'
  kstat -p zfs:0:arcstats:size 2>/dev/null || true
  kstat -p zfs:0:arcstats:c 2>/dev/null || true
  kstat -p zfs:0:arcstats:c_max 2>/dev/null || true
  kstat -p zfs:0:arcstats:hits 2>/dev/null || true
  kstat -p zfs:0:arcstats:misses 2>/dev/null || true
} >"$OUT/arc.txt"

run_capture zpool-list.txt zpool list -Hp
run_capture zpool-iostat.txt zpool iostat -v 1 5

{
  echo '# INPSan state/data footprint (KiB)'
  du -sk /var/inpsan/monitor 2>/dev/null || true
  du -sk /var/inpsan/alerts 2>/dev/null || true
  du -sk /opt/inpsan 2>/dev/null || true
} >"$OUT/storage-footprint.txt"

{
  for f in /opt/inpsan/dashboard/VERSION /opt/inpsan/dashboard/BUILD /opt/inpsan/alert-engine/VERSION /opt/inpsan/alert-engine/BUILD /opt/inpsan/hardware-topology-telemetry/VERSION /opt/inpsan/io-telemetry/VERSION /opt/inpsan/notification-engine/BUILD /opt/inpsan/notification-center/BUILD; do
    if [ -f "$f" ]; then
      printf '%s: ' "$f"
      cat "$f"
    fi
  done
  echo
  if [ -x /opt/inpsan/alert-engine/bin/inpsan-alertctl ]; then
    /opt/inpsan/alert-engine/bin/inpsan-alertctl status 2>&1
  fi
} >"$OUT/inpsan-status.txt"

echo "capture_complete=true" >>"$OUT/manifest.txt"
echo "INPSan benchmark evidence written to: $OUT"
echo "Review for sensitive identifiers before external sharing."