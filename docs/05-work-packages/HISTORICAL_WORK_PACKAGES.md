# INPSan Historical Work Packages

Reconstruction date: `2026-08-05`

This file captures the engineering purpose, problem, method and result of the major completed or active work packages.

## INPSAN-WP-GUI-001 — Web GUI Golden Baseline

- **Problem:** customized UI work needed a stable recovery and comparison point.
- **Method:** consolidate accepted GUI changes into a complete packaged baseline.
- **Result:** INPSan Complete Web GUI v3.1.13.
- **Status:** `PASS`.

## INPSAN-WP-MON-001 — Monitoring Foundation and SMF Stabilization

- **Problem:** monitoring needed persistent, native service execution and reliable runtime output.
- **Method:** correct SMF service integration, define telemetry schema/contract, verify native runtime and history.
- **Result:** Monitoring Foundation v3.2.0.5; service online; native verification passed.
- **Status:** `PASS`.

## INPSAN-WP-DASH-001 — Historical Dashboard and Epoch Time Axis

- **Problem:** historical views and time-axis behavior were not sufficiently reliable.
- **Method:** correct history delay/selection behavior and use epoch-based time handling; validate 1h/6h/24h/7d ranges.
- **Result:** Dashboard v3.2.1.6 historical baseline.
- **Status:** `PASS`.

## INPSAN-WP-HW-001 — Hardware Health and Inventory

- **Problem:** server/controller health and physical inventory were incomplete.
- **Method:** integrate native hardware sources, recognize HPE H240 through `smrt`, expose SAS/HBA, fan and temperature data.
- **Result:** Hardware Health & Inventory v3.2.0.11-r2.
- **Status:** `PASS`.

## INPSAN-WP-HW-002 — iLO/Redfish Integration

- **Problem:** host-local telemetry alone could not provide all chassis and platform-health data.
- **Method:** integrate HPE iLO 5 Redfish data into the monitoring foundation.
- **Result:** iLO/Redfish v3.2.0.12-r1 online.
- **Status:** `PASS`.

## INPSAN-WP-DASH-002 — Chassis Visualization

- **Problem:** operators needed physical context for disk and hardware state.
- **Method:** implement approved 24-bay front and 12-bay rear layouts, LED/state logic and health visualization.
- **Result:** Dashboard visualization v3.2.2.8-r2.
- **Status:** `PASS` for layout/visual baseline.

## INPSAN-WP-FC-001 — Fibre Channel Foundation

- **Problem:** validate enterprise block-storage connectivity and QLogic HBA behavior.
- **Method:** test COMSTAR target workflow and QLogic initiator workflow; verify online 16 Gb initiator link.
- **Result:** tested FC foundation available.
- **Status:** `PASS` for tested modes; production design remains configuration-dependent.

## INPSAN-WP-ISCSI-001 — iSCSI/STMF Foundation

- **Problem:** validate IP-based block target services.
- **Method:** verify STMF and iSCSI target services and LU online state.
- **Result:** functional tested foundation.
- **Status:** `PASS` for tested configuration.

## INPSAN-WP-ALT-001 — Alert Engine and Event Store

- **Problem:** telemetry required durable event processing and operator-visible alert lifecycle.
- **Method:** separate event persistence from alert evaluation and integrate dashboard presentation.
- **Result:** Alert Engine/Event Store v3.2.3.0 and Dashboard Alerting & Operations v3.2.3.1.
- **Status:** `PASS` for core engine and display.

## INPSAN-WP-DASH-003 — Accessibility and Readability Correction

- **Problem:** menus, submenus and select controls could render dark text on dark surfaces; typography was too small even at high browser zoom.
- **Method:** explicit high-contrast surfaces, dark readable text, increased typography, clear focus states and broader dashboard sizing corrections.
- **Result:** Dashboard Accessibility & Readability v3.2.3.1-r1.
- **Status:** `PASS`.

## INPSAN-WP-HW-003 — Persistent Disk Identity and Bay Reconciliation

- **Problem:** physical bay state must remain correct across removal, failure, reinsertion and new-disk insertion.
- **Method:** reconcile persistent disk identity with controller/enclosure/slot instead of trusting transient device paths.
- **Result:** architecture and corrective implementation work completed in stages.
- **Status:** `PARTIAL PASS`; complete Bay 2, Bay 6/7 and repeated remove/reinsert acceptance is pending.

## INPSAN-WP-DASH-004 — Dashboard Corrective Stabilization v3.2.4.3

- **Problem:** remaining theme/font/contrast/widget-layout and chassis-mapping corrections required a consolidated package.
- **Method:** package corrective changes with preflight validation and hash verification.
- **Result:** SHA verified and `[9/9] Preflight successful` on the correct INPSan host.
- **Status:** `AWAITING VALIDATION`; installation and visual acceptance are not yet confirmed.
