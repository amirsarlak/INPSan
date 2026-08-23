# INPSan Historical Work Packages

Reconstruction date: `2026-08-05`  
Last update: `2026-08-23`

This file captures the engineering purpose, problem, method and result of major completed or active work packages.

## INPSAN-WP-GUI-001 — Web GUI Golden Baseline

- **Result:** INPSan Complete Web GUI v3.1.13.
- **Status:** `PASS`.

## INPSAN-WP-MON-001 — Monitoring Foundation and SMF Stabilization

- **Result:** Monitoring Foundation v3.2.0.5; service online; native verification passed.
- **Status:** `PASS`.

## INPSAN-WP-DASH-001 — Historical Dashboard and Epoch Time Axis

- **Result:** Dashboard v3.2.1.6 historical baseline with validated ranges and epoch time handling.
- **Status:** `PASS`.

## INPSAN-WP-HW-001 — Hardware Health and Inventory

- **Result:** Hardware Health & Inventory v3.2.0.11-r2 with H240 `smrt`, SAS/HBA, fans and temperatures.
- **Status:** `PASS`.

## INPSAN-WP-HW-002 — iLO/Redfish Integration

- **Result:** iLO/Redfish v3.2.0.12-r1 online.
- **Status:** `PASS`.

## INPSAN-WP-DASH-002 — Chassis Visualization

- **Result:** approved 24-Bay front and 12-Bay rear layouts and state visualization.
- **Status:** `PASS` for visual foundation; later physical-truth corrections are recorded below.

## INPSAN-WP-FC-001 — Fibre Channel Foundation

- **Result:** tested QLogic target/initiator workflows and online 16 Gb initiator link.
- **Status:** `PASS` for tested modes; production design remains configuration-dependent.

## INPSAN-WP-ISCSI-001 — iSCSI/STMF Foundation

- **Result:** functional STMF/iSCSI target services and LU online state.
- **Status:** `PASS` for tested configuration.

## INPSAN-WP-ALT-001 — Alert Engine and Event Store

- **Result:** durable alert/event foundation, later advanced to v3.2.3.0-r1 for current-adapter lifecycle processing.
- **Status:** `PASS`.

## INPSAN-WP-DASH-003 — Accessibility and Readability Correction

- **Result:** high-contrast controls, readable typography and clear focus states.
- **Status:** `PASS`.

## INPSAN-WP-HW-003 — Persistent Disk Identity and Bay Reconciliation

- **Problem:** transient logical enumeration and retained OS records did not reliably represent physical occupancy.
- **Method:** use H240 Port/Box/Bay/Serial events as physical truth and correlate them with current persistent disk identity.
- **Result:** H240 topology v3.2.0.11-r3, exact expected identities and verified live occupancy.
- **Status:** `PASS`; Bay 2, Bay 6 and Bay 7 remove/reinsert tests completed.

## INPSAN-WP-DASH-004 — Dashboard Corrective Stabilization

- **Problem:** theme, contrast, layout and initial chassis projection defects remained after earlier candidates.
- **Method:** staged corrective packages with preflight, native verification, visual QA and rollback coverage.
- **Result:** final accepted Dashboard v3.2.4.6-ui1.
- **Status:** `PASS`; earlier v3.2.4.3 acceptance-pending statement is superseded.

## INPSAN-WP-ZFS-001 — Physical Disk to ZFS Correlation

- **Problem:** disks displayed as pool-unassigned and ZFS-unknown despite valid pool membership.
- **Method:** correlate pool leaf identity, device path and persistent WWN identity.
- **Result:** Dashboard/DataAdapter v3.2.4.5 and later baselines report pool, VDEV and ZFS state correctly.
- **Status:** `PASS`.

## INPSAN-WP-IO-001 — Ten-Second Live I/O

- **Problem:** the full monitoring cadence was too slow for current disk operations.
- **Method:** dedicated read-only 10-second `iostat` service without changing the 60-second collector.
- **Result:** Live I/O v3.2.0.13 and compact disk operations in Dashboard v3.2.4.6.
- **Status:** `PASS`.

## INPSAN-WP-ALT-002 — Physical-Bay Alert Lifecycle

- **Problem:** the long-running Alert Engine retained an older DataAdapter and did not process current physical-Bay transitions reliably.
- **Method:** load and identify DataAdapter 3.2.4.6, reload safely, open physical-Bay alerts immediately and resolve after healthy stability cycles.
- **Result:** Alert Engine v3.2.3.0-r1; independent Bay 6/7 incidents opened and resolved with history retained.
- **Status:** `PASS`.

