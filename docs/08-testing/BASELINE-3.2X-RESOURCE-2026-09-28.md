# INPSan 3.2.x Initial Resource Benchmark Baseline

**Capture:** 2026-09-28 13:35 +03:30  
**Collector:** 0.1.0-dev  
**Classification:** PASS — initial low-load/reference snapshot; not a saturation/performance ceiling test

## 1. Platform

- OmniOS: `omnios-r151054-a30603e36a` / branch `151054.0`.
- Uptime at capture: approximately 5h25m.
- Load average: `0.32 / 0.31 / 0.30`.
- Benchmark capture completed without reported command errors.

## 2. INPSan runtime

- 10 INPSan SMF services observed online.
- Dashboard: `3.2.4.6-ui2-r1`.
- Alert Engine: `3.2.3.0-r3-r2`.
- Hardware Topology Telemetry: `3.2.0.11-r4`.
- Live I/O: `3.2.0.13`.
- Notification Engine: `3.2.4.0-r1`.
- Notification Center: `3.2.4.1`.

Alert Engine snapshot:
- `ok=true`;
- health=`warning`;
- active_count=`1`;
- raw source alerts=`2`, policy-filtered=`1`;
- last engine duration=`276 ms`;
- topology mapping=`verified_live`;
- physical slots=`24`, verified physical slots=`24`.

The benchmark output does not identify the remaining active warning category, therefore no RCA conclusion is made from this capture.

## 3. CPU and memory

Solaris `mpstat 1 5` exposed 72 logical CPUs. Excluding the first since-boot-style sample and averaging the four interval samples:
- approximate aggregate idle: `99.61%`;
- approximate busy: `0.39%`;
- no sampled CPU wait time.

`vmstat 1 5` interval samples showed:
- free memory around `29,084,000 KiB` (~27.74 GiB);
- `pi=0` and `po=0` in interval samples;
- effectively idle CPU at host level.

This is a low-load baseline, not a stress result.

## 4. ARC

- current ARC size: `956,452,880 bytes` (~912.1 MiB);
- ARC target `c`: `16 GiB`;
- ARC ceiling `c_max`: `16 GiB`;
- hits: `19,409,734`;
- misses: `4,151,118`;
- calculated hit ratio: approximately `82.38%`.

The configured 16 GiB ARC ceiling remains active while actual ARC occupancy at capture was below 1 GiB.

## 5. Storage capacity

| Pool | Allocated | Free | Reported capacity use | Health |
|---|---:|---:|---:|---|
| Pool-1800GB | ~191 GiB | ~1.44 TiB | 11% | ONLINE |
| Pool-300G | ~36.3 GiB | ~242 GiB | 13% | ONLINE |
| SSD-POOL | ~96.8 GiB | ~141 GiB | 40% | ONLINE |
| rpool | ~15.7 GiB | ~262 GiB | 5% | ONLINE |

Across the short `zpool iostat` interval, data pools were largely idle. One interval showed rpool activity around 22 read ops/s and 161 write ops/s with ~1.49 MiB/s read and ~956 KiB/s write. This must not be interpreted as a performance limit.

## 6. INPSan footprint

- `/var/inpsan/monitor`: `94,895 KiB` (~92.67 MiB).
- `/var/inpsan/alerts`: `91 KiB`.
- `/opt/inpsan`: `288 KiB` as reported by this `du` capture.

A single snapshot cannot establish daily growth rate.

## 7. Validation result

**Collector v0.1.0-dev validation: PASS for initial non-destructive capture.**

No unsupported-command or permission errors appeared in the submitted outputs. The collector successfully captured host, service, process, ARC, ZFS capacity/I/O and footprint evidence without changing product state.

## 8. Gaps for collector v0.1.1

The first run intentionally remains lightweight. The next revision should add:
- per-process/service RSS and CPU measurements;
- `zpool status -x` health evidence;
- device latency/service-time evidence (`iostat -xn` where supported);
- timed DataAdapter read latency;
- network/link counters;
- history footprint breakdown suitable for growth analysis.

These enhancements do not invalidate this initial baseline.

## 9. Security note

Raw evidence contains hostname and storage device identifiers. It is internal engineering evidence and should be sanitized before inclusion in an external knowledge-based/certification dossier.