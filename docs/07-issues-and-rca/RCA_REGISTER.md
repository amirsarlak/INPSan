# INPSan Root Cause and Corrective Action Register

## INPSAN-RCA-MON-001 — Monitoring service instability

- **Symptom:** monitoring service/runtime was not yet a dependable native baseline.
- **Root cause class:** SMF/service integration and runtime packaging defects.
- **Corrective action:** Monitoring Foundation revisions through v3.2.0.5; native verification.
- **Status:** `RESOLVED / PASS`.

## INPSAN-RCA-DASH-001 — Historical timing and axis behavior

- **Symptom:** historical dashboard delay/range behavior and time-axis representation required correction.
- **Root cause class:** history handling and time-axis implementation.
- **Corrective action:** epoch-based handling and validation of supported ranges.
- **Status:** `RESOLVED / PASS` in validated dashboard history baseline.

## INPSAN-RCA-HW-001 — HPE H240 not represented correctly

- **Symptom:** controller/hardware inventory was incomplete.
- **Root cause class:** driver/source recognition mismatch.
- **Corrective action:** recognize the H240 through OmniOS `smrt` and integrate native hardware inventory.
- **Status:** `RESOLVED / PASS` for inventory/topology representation.

## INPSAN-RCA-DASH-002 — Low contrast and undersized UI

- **Symptom:** dark text could appear on dark menu/select surfaces; fonts remained difficult to read at 150% zoom.
- **Root cause class:** insufficiently explicit theme contrast and typography rules across controls/browsers.
- **Corrective action:** high-contrast light surfaces, dark text, larger typography and clear focus states.
- **Status:** `RESOLVED / PASS` in v3.2.3.1-r1.

## INPSAN-RCA-HW-002 — Physical bay identity ambiguity

- **Symptom:** a disk must stay associated with the correct physical bay through removal, failure and reinsertion.
- **Root cause class:** transient enumeration cannot guarantee stable logical-to-physical identity.
- **Corrective action:** persistent disk identity plus enclosure/slot reconciliation.
- **Status:** `PARTIAL PASS`; topology baseline is verified but full lifecycle acceptance testing remains pending.

## INPSAN-RCA-PANIC-001 — H240 / smrt kernel panic

- **Incident time:** `2026-08-05 18:43:05 +03:30`.
- **FMA UUID:** `5dc99e1e-95ee-4871-9791-ec40e8744d10`.
- **Symptom:** kernel panic during `smrt` physical-target deactivation/free path.
- **Panic signature:** assertion failure `list_is_empty(&smpt->smpt_targets)` in `smrt_physical_free()` with stack through `smrt_phys_tgtmap_deactivate()`.
- **Correlated evidence:** ZFS I/O/probe failure immediately before panic and temporary post-reboot device/pool-open failures.
- **Root cause class:** `OPEN`; confirmed real H240/illumos `smrt` driver-path defect or inconsistent target-deactivation state. Exact initiating hardware/driver condition remains under investigation.
- **Corrective action:** preserve crash evidence; do not acquit case; avoid unsafe reproduction on production; investigate offline/build-matched dump and firmware/kernel/driver paths.
- **Status:** `OPEN / HIGH-RISK DRIVER RCA`.

## INPSAN-RCA-PANIC-002 — pageout_deadman during savecore extraction

- **Incident time:** `2026-09-09 09:02:09 +03:30`.
- **FMA UUID:** `5c61c9de-cca3-4b1e-abbf-6b0334af7119`.
- **Symptom:** kernel panic while `savecore` was extracting the Aug 05 compressed crash dump.
- **Panic string:** `pageout_deadman: stuck pushing the same page for 90 seconds (freemem is 275889)`.
- **Pre-panic telemetry:** RAM sustained approximately `96.7–97.1%`; last pre-panic sample `96.78%`; ARC approximately `25.29 GiB` on a system with approximately `32 GiB` RAM.
- **Previous ARC maximum:** approximately `30.16 GiB`.
- **Root cause class:** high-confidence memory-pressure/pageout forward-progress failure triggered by the crash-dump extraction workload. The exact lower-level blocking component below `VOP_PUTPAGE()` is not yet isolated.
- **Corrective action:** suspend production `savecore` extraction; persist `zfs_arc_max=16 GiB`; update boot archive; controlled reboot; verify `c_max=17179869184`; preserve both crash dumps and keep both panic cases open.
- **Post-correction validation:** all pools healthy; 16 GiB ARC ceiling active after reboot.
- **Status:** `MITIGATED / PASS FOR STABILIZATION`, with low-level RCA still `OPEN`.

## INPSAN-RCA-DASH-003 — P1 alert-action packaging cleanup

- **Symptom:** accepted browser action path still has packaging/metadata cleanup items after r13-derived fixes.
- **Open items:** canonical asset query, audit `remote`, stale engine-version metadata, and several-second state synchronization latency.
- **Status:** `OPEN / CLEANUP REQUIRED`; functional alert-action acceptance is not reverted.
