# INPSan Current Operational State

State date: `2026-08-05 23:22 +03:30`  
Classification: `RECONSTRUCTED FROM APPROVED PROJECT RECORD`

## Stable operational foundation

- OmniOS r151054;
- Web GUI Golden v3.1.13;
- Monitoring Foundation v3.2.0.5;
- telemetry schema 1.1 and contract 1.0;
- Dashboard and historical telemetry foundation;
- hardware health/inventory and H240 `smrt` detection;
- iLO/Redfish integration;
- chassis visualization;
- Alert Engine and Event Store;
- alert display and accessibility/readability corrections.

## Storage and protocol state

- OpenZFS pools and `rpool` were operational at the validated checkpoints.
- A historical `rpool` checksum count was observed and must remain visible in operational review rather than silently discarded.
- COMSTAR/STMF and iSCSI target foundations were online in tested configurations.
- QLogic FC was tested in target and initiator workflows; the validated operational test cited an online 16 Gb initiator link.

## Hardware state requiring controlled validation

The last operator-reported physical front-bay state used for the next validation plan was:

- Bay 1: 300 GB disk associated with `rpool`;
- Bay 2: 300 GB `rpool` member intentionally removed for corrective testing;
- Bays 3 and 4: approximately 1.8 TB disks;
- Bay 5: 300 GB disk in the 300 GB pool;
- Bays 6 and 7: empty before planned insertion tests;
- Bay 8: 256 GB SSD;
- Bays 9–24: empty.

This operator-reported state is the acceptance reference. A package projection or inferred mapping must not override physical verification.

## Current pending actions

1. Install and validate Dashboard Corrective Stabilization v3.2.4.3; preflight alone is not acceptance.
2. Complete browser and visual QA, including Chrome and zoom/readability checks.
3. Validate Bay 2 reinsertion and error-state recovery.
4. Insert new disks in Bays 6 and 7 and verify deterministic discovery.
5. Execute repeated removal/reinsert tests for occupied bays.
6. Validate missing/failed/recovered state transitions without stale alerts.
7. Keep notification channels disabled.
8. Resolve NTP synchronization and record evidence.

## Evidence limitations

Historical package names and PASS states are documented, but not all raw logs/screenshots from earlier conversations are present in GitHub. Those items are marked as reconstructed records and should be enriched with retained evidence where available.
