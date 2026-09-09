# INPSan Checkpoint — P2 ARC Stabilization and Kernel Panic RCA

Checkpoint ID: `CP-20260909-P2-ARC-01`  
Date: `2026-09-09`  
Status: `PASS WITH OPEN RCA ITEMS`

## Scope

This checkpoint records the validated response to the second kernel panic observed during crash-dump extraction and the resulting ZFS ARC stabilization change.

## Verified incident evidence

### Incident A — 2026-08-05 smrt kernel panic

- FMA UUID: `5dc99e1e-95ee-4871-9791-ec40e8744d10`
- Class: `defect.sunos.kernel.panic`
- Panic signature: assertion failure in `smrt_physical_free()` / `smrt_phys_tgtmap_deactivate()`.
- Status: `OPEN`; independent driver-path RCA remains required.

### Incident B — 2026-09-09 pageout deadman panic

- FMA UUID: `5c61c9de-cca3-4b1e-abbf-6b0334af7119`
- Panic time: `2026-09-09 09:02:09 +03:30`
- Panic string: `pageout_deadman: stuck pushing the same page for 90 seconds (freemem is 275889)`.
- Crash dump preserved as `/var/crash/vmdump.1`.
- `savecore` had been extracting `/var/crash/vmdump.0` when the system panicked.
- Exact low-level blocking component below `VOP_PUTPAGE()` is not yet isolated.

## Historical memory correlation

INPSan Dashboard cache provided one-minute samples before the panic.

- Physical memory: approximately `32425 MB`.
- RAM use remained approximately `96.7–97.1%` for at least the captured hour before the panic.
- Last pre-panic sample: `2026-09-09 08:53:06 +03:30`.
- Last pre-panic `memory_pct`: `96.78%`.
- Last pre-panic ARC size: `27154376576` bytes, approximately `25.29 GiB`.
- Kernel panic reported approximately `1.05 GiB` free memory, consistent with the telemetry headroom.
- Prior ARC maximum: `32380760064` bytes, approximately `30.16 GiB`.

Classification: high-confidence contributing condition and trigger chain is `sustained high memory/ARC occupancy + savecore workload -> pageout forward-progress failure -> pageout_deadman panic`. This does not prove the exact lower-layer blocking component.

## Corrective stabilization

A persistent ARC maximum of `16 GiB` was configured using:

`/etc/system.d/inpsan:zfs-arc`

with:

```text
set zfs:zfs_arc_max = 17179869184
```

The boot archive was updated and a controlled reboot was performed.

## Post-reboot validation

Validated runtime values:

- `zfs:0:arcstats:c_max = 17179869184`
- `zfs:0:arcstats:c = 17179869184`
- initial ARC `size = 560081576` bytes
- all ZFS pools healthy
- all pools ONLINE
- swap available and no immediate pageout activity observed in interval samples
- both historical kernel-panic FMA cases intentionally remain open

Result: `P2.3F-B ARC Boot Activation = PASS`.

## Safety decision

Until the RCA is further isolated:

- do not repeat `savecore` extraction on the production INPSan appliance;
- preserve `vmdump.0`, `vmdump.1`, and the partial extraction directory;
- do not acquit either kernel-panic FMA case;
- perform crash-dump analysis offline or on a build-matched clone where practical.

## Pending

1. Observe ARC and total memory under normal workload with the 16 GiB ceiling.
2. Confirm historical telemetry remains stable and memory does not return to the previous 96–97% steady state.
3. Continue Incident A `smrt` driver RCA separately.
4. Isolate the exact lower-level cause of the Incident B `VOP_PUTPAGE` stall if additional evidence becomes available.
5. Resume hardware-health and physical-bay stability work only after memory stabilization is accepted.

## Baseline decision

The `16 GiB` ARC ceiling is accepted as an operational stabilization baseline. It is not yet a performance-optimized final value; later tuning may be performed only with evidence and controlled testing.
