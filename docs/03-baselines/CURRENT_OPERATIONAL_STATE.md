# INPSan Current Operational State

State date: `2026-09-09`  
Classification: `CURRENT VERIFIED OPERATIONAL STATE`

## Stable operational foundation

- OmniOS `r151054`;
- Web GUI Golden `v3.1.13`;
- Dashboard/DataAdapter `v3.2.4.6`;
- accepted Dashboard Alert Action / Hardware Aggregate baseline `v3.2.4.6-ui2-r1` with later P1 action-path hotfix work pending package cleanup;
- Alert Engine aggregate hotfix `v3.2.3.0-r3-r2`;
- Alert schema `1.1`, Event schema `1.0`, Operations schema `1.8`;
- Monitoring Foundation `v3.2.0.5`;
- H240 topology baseline `v3.2.0.11-r4`, physical topology 24/24 verified;
- iLO/Redfish telemetry extension `3.2.0.12`, connected/fresh at validated checkpoint;
- notification channels remain disabled.

## Storage state

- `Pool-1800GB`, `Pool-300G`, `SSD-POOL`, and `rpool` are ONLINE at the latest validation.
- `zpool status -x` reports all pools healthy.
- `rpool` is a mirror of two HP 300 GB disks.
- No current ZFS READ/WRITE/CKSUM errors were observed in the latest post-reboot validation.

## Kernel panic / FMA state

Two kernel-panic FMA cases remain intentionally open:

1. `5dc99e1e-95ee-4871-9791-ec40e8744d10` — Aug 05 `smrt` assertion panic in the H240 driver path. RCA remains open.
2. `5c61c9de-cca3-4b1e-abbf-6b0334af7119` — Sep 09 `pageout_deadman` panic while `savecore` was extracting the previous dump.

The second panic is not the same signature as the first.

## Verified memory correlation for Sep 09 panic

INPSan Dashboard history shows sustained pre-panic memory pressure:

- memory utilization approximately `96.7–97.1%` across the captured pre-panic hour;
- last pre-panic sample at `08:53:06 +03:30`: `memory_pct=96.78%`;
- ARC size at that sample: `27154376576` bytes, approximately `25.29 GiB`;
- physical memory approximately `32425 MB`;
- panic string reported `freemem=275889` pages, approximately `1.05 GiB` free;
- previous ARC maximum was approximately `30.16 GiB`.

High-confidence contributing chain: sustained high ARC/total-memory occupancy plus the crash-dump extraction workload led to a pageout forward-progress failure and `pageout_deadman` panic. The exact lower-level blocking component below `VOP_PUTPAGE()` is not yet isolated.

## ARC stabilization baseline

Persistent configuration:

`/etc/system.d/inpsan:zfs-arc`

```text
set zfs:zfs_arc_max = 17179869184
```

Post-reboot verification:

- `zfs:0:arcstats:c_max = 17179869184`;
- `zfs:0:arcstats:c = 17179869184`;
- pools healthy after controlled reboot.

Short-term normal-operation warm-up validation:

- ARC grew from approximately `9.40 GiB` to `14.92 GiB` over six one-minute samples;
- ARC remained below the fixed 16 GiB ceiling;
- final `vmstat` free memory approximately `11.9 GiB`;
- no sampled page-out activity;
- all pools remained healthy;
- no new FMA panic case appeared.

Status: `PASS` as an operational stabilization baseline, including short-term warm-up validation. The 16 GiB value is not yet declared the final performance-optimal value.

## Safety restrictions currently in force

- Do not rerun `savecore` extraction on the production appliance.
- Preserve `/var/crash/vmdump.0` and `/var/crash/vmdump.1`.
- Preserve the partial extraction directory `/var/crash/INPSan-smrt-RCA-20260805`.
- Do not acquit either kernel-panic FMA case yet.
- Prefer build-matched offline/clone crash-dump analysis.

## Current pending actions

1. Continue ordinary telemetry observation of the 16 GiB ARC baseline without production stress reproduction.
2. Continue the independent Aug 05 `smrt` driver RCA using read-only evidence first.
3. Continue low-level RCA of the Sep 09 pageout stall only with non-disruptive evidence or offline dump analysis.
4. Complete P1 alert-action packaging cleanup: canonical asset query, audit `remote`, engine-version metadata and UI sync latency.
5. Resume hardware-health reconciliation and physical-bay lifecycle stability after the remaining driver-risk review.
6. Keep outbound notification channels disabled.
