# INPSan Test & Evidence — P2 ARC Stabilization

Test ID: `TE-20260909-P2-ARC-01`  
Date: `2026-09-09`  
Reference checkpoint: `CP-20260909-P2-ARC-01`  
Result: `PASS — SHORT-TERM WARM-UP STABILITY`

## Purpose

Validate that the persistent 16 GiB ZFS ARC ceiling remains active after reboot and prevents a return to the pre-panic critical memory state during normal post-boot ARC warm-up.

## Pre-change incident evidence

- Physical memory: approximately 32425 MB.
- Pre-panic memory utilization: approximately 96.7–97.1% for the captured hour.
- Last pre-panic sample: 2026-09-09 08:53:06 +03:30.
- Last pre-panic memory utilization: 96.78%.
- Last pre-panic ARC size: 27154376576 bytes (~25.29 GiB).
- Panic free-memory evidence: `freemem=275889` pages (~1.05 GiB).
- Previous ARC maximum: 32380760064 bytes (~30.16 GiB).

## Applied stabilization

Persistent setting:

```text
/etc/system.d/inpsan:zfs-arc
set zfs:zfs_arc_max = 17179869184
```

Post-reboot runtime verification:

- `c_max = 17179869184`
- `c = 17179869184`
- pools healthy and ONLINE.

## Warm-up observation

Six one-minute samples were collected under normal operation:

| Sample | Time +03:30 | ARC size bytes | ARC approx GiB | vmstat free KB | Page-out | Pools |
|---|---|---:|---:|---:|---:|---|
| 1 | 10:55:58 | 10090205880 | 9.40 | 18762368 | 0 | healthy |
| 2 | 10:56:59 | 11090969944 | 10.33 | 17666572 | 0 | healthy |
| 3 | 10:58:01 | 12293447096 | 11.45 | 16268072 | 0 | healthy |
| 4 | 10:59:02 | 13926560424 | 12.97 | 14588308 | 0 | healthy |
| 5 | 11:00:03 | 14916250232 | 13.89 | 13544160 | 0 | healthy |
| 6 | 11:01:04 | 16016094264 | 14.92 | 12443952 | 0 | healthy |

## Acceptance observations

- `c_max` remained exactly `17179869184` in all samples.
- ARC grew normally toward the 16 GiB ceiling but did not exceed it.
- At sample 6, ARC was approximately 14.92 GiB while approximately 11.9 GiB of free memory remained according to `vmstat`.
- No page-out activity was observed in the interval samples.
- `zpool status -x` remained `all pools are healthy` for every sample.
- No new FMA panic case was created; only the two known historical panic cases remain open.

## Decision

`P2.3G Short-Term Stability = PASS`.

The 16 GiB ARC ceiling is retained as the accepted operational stabilization baseline. This is not a final performance-tuning determination. Production `savecore` extraction remains suspended and both kernel-panic FMA cases remain intentionally open.
