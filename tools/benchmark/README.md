# INPSan 3.3 Benchmark Harness

Branch status: **development candidate — not an accepted product package**

Purpose: capture a reproducible, non-destructive resource/performance baseline from an INPSan node before 3.3 services are added.

## Safety

The collector does not change pools, datasets, alerts, services, routes or configuration. It creates only a timestamped evidence directory under /var/tmp unless another output directory is specified.

Do not run synthetic high-I/O workloads on production data. This first collector only observes the current system.

## Usage

Run as a user with sufficient read access:

    /usr/bin/bash inpsan-benchmark-collect.sh

Optional output root:

    /usr/bin/bash inpsan-benchmark-collect.sh /var/tmp/my-benchmark

## Output

- host.txt
- services.txt
- processes.txt
- vmstat.txt
- mpstat.txt
- arc.txt
- zpool-list.txt
- zpool-iostat.txt
- storage-footprint.txt
- inpsan-status.txt
- manifest.txt

Before sharing externally, review evidence for hostnames, addresses, serials or other sensitive identifiers.