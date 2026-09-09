# INPSan Continuation Point

Checkpoint time: `2026-09-09`  
Reference checkpoint: `CP-20260909-P2-ARC-01`

## Immediate objective

Validate memory/ARC stability under normal operation after applying the 16 GiB ARC ceiling, while preserving both kernel-panic cases for continued RCA.

## Current accepted stabilization

- Persistent ARC ceiling: `zfs_arc_max = 17179869184` (16 GiB).
- Runtime post-reboot verification: `c_max = 17179869184`.
- All pools healthy and ONLINE after controlled reboot.
- No production `savecore` re-test is permitted at this stage.

## Next execution sequence

1. Observe ARC size and total memory under normal production-like workload.
2. Confirm memory does not return to the former sustained `96–97%` range.
3. Verify no new pageout/panic/FMA case appears during ordinary operation.
4. Preserve `/var/crash/vmdump.0`, `/var/crash/vmdump.1`, and `/var/crash/INPSan-smrt-RCA-20260805`.
5. Keep FMA UUID `5dc99e1e-95ee-4871-9791-ec40e8744d10` open for the Aug 05 `smrt` panic RCA.
6. Keep FMA UUID `5c61c9de-cca3-4b1e-abbf-6b0334af7119` open until stabilization observation and offline RCA are complete.
7. Perform any further crash-dump analysis on a build-matched offline/clone environment where practical.
8. Complete P1 alert-action cleanup: canonical asset query, audit `remote`, current engine-version metadata and frontend state-sync latency.
9. Resume hardware-health reconciliation and physical-bay lifecycle stability validation after the memory gate passes.
10. Keep all outbound notification channels disabled.

## Acceptance gate for ARC stabilization

The 16 GiB stabilization baseline may remain accepted if normal operation shows:

- `c_max` remains exactly `17179869184`;
- no sustained return to critical memory occupancy;
- no new pageout-deadman panic;
- no storage regression;
- ZFS pools remain healthy;
- no evidence that the ARC ceiling materially breaks the validated SAN/NAS workload.

The value is a safe operational ceiling, not yet a final performance-tuned value. Any increase (for example 18 or 20 GiB) requires separate evidence and controlled testing.

## Separate unresolved RCA

The Aug 05 H240/`smrt` kernel panic remains an independent high-risk driver-path RCA and must not be considered resolved by the ARC mitigation.
