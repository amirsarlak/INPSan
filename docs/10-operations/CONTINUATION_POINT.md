# INPSan Continuation Point

Checkpoint time: `2026-09-09`  
Reference checkpoint: `CP-20260909-P2-ARC-01`

## Immediate objective

Proceed from the accepted ARC stabilization gate to the independent Aug 05 H240/`smrt` kernel-panic RCA using non-disruptive, read-only evidence first.

## Current accepted stabilization

- Persistent ARC ceiling: `zfs_arc_max = 17179869184` (16 GiB).
- Runtime post-reboot verification: `c_max = 17179869184`.
- P2.3G short-term warm-up stability: `PASS`.
- ARC reached approximately `14.92 GiB` while approximately `11.9 GiB` memory remained free in the final sample.
- No page-out activity was observed in the sampled intervals.
- All pools remained healthy.
- No new FMA panic case appeared.
- No production `savecore` re-test is permitted at this stage.

## Next execution sequence

1. Continue the Aug 05 H240/`smrt` panic RCA with current controller, driver, firmware, device-path and FMA correlation evidence only.
2. Do not intentionally reproduce disk removal/reset conditions on production while the `smrt` panic RCA is open.
3. Preserve `/var/crash/vmdump.0`, `/var/crash/vmdump.1`, and `/var/crash/INPSan-smrt-RCA-20260805`.
4. Keep FMA UUID `5dc99e1e-95ee-4871-9791-ec40e8744d10` open for the Aug 05 `smrt` panic RCA.
5. Keep FMA UUID `5c61c9de-cca3-4b1e-abbf-6b0334af7119` open until the pageout mitigation has adequate ordinary-operation history and any offline RCA is complete.
6. Retain normal telemetry observation of ARC/memory without dedicated stress reproduction.
7. Perform further crash-dump extraction/analysis only on a build-matched offline/clone environment where practical.
8. Complete P1 alert-action cleanup: canonical asset query, audit `remote`, current engine-version metadata and frontend state-sync latency.
9. Resume aggressive physical-bay removal/reinsert lifecycle testing only after the `smrt` driver-risk gate is reviewed.
10. Keep all outbound notification channels disabled.

## ARC stabilization acceptance

The 16 GiB stabilization baseline currently passes:

- exact runtime `c_max = 17179869184`;
- controlled reboot activation;
- short-term normal-operation ARC warm-up;
- healthy ZFS pools;
- no sampled page-out;
- no new panic/FMA event.

The value remains a safe operational ceiling, not a final performance-tuned value. Any increase requires separate evidence and controlled testing.

## Separate unresolved RCA

The Aug 05 H240/`smrt` kernel panic remains an independent high-risk driver-path RCA and must not be considered resolved by the ARC mitigation.
