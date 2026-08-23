# INPSan Root Cause and Corrective Action Register

## INPSAN-RCA-MON-001 — Monitoring service instability

- **Corrective action:** Monitoring Foundation revisions through v3.2.0.5 and native verification.
- **Status:** `RESOLVED / PASS`.

## INPSAN-RCA-DASH-001 — Historical timing and axis behavior

- **Corrective action:** epoch-based handling and validation of supported ranges.
- **Status:** `RESOLVED / PASS` in v3.2.1.6.

## INPSAN-RCA-HW-001 — HPE H240 inventory recognition

- **Corrective action:** recognize H240 through OmniOS `smrt` and integrate native hardware inventory.
- **Status:** `RESOLVED / PASS` in v3.2.0.11-r2.

## INPSAN-RCA-DASH-002 — Low contrast and undersized UI

- **Corrective action:** high-contrast controls, readable typography and focus states.
- **Status:** `RESOLVED / PASS`.

## INPSAN-RCA-HW-002 — Physical Bay identity ambiguity

- **Symptom:** logical discovery order and retained device records produced incorrect Bay occupancy.
- **Root cause:** transient enumeration was treated as physical truth.
- **Corrective action:** H240 Port/Box/Bay/Serial event correlation, exact expected identity and stale-record suppression.
- **Status:** `RESOLVED / PASS` in topology v3.2.0.11-r3.

## INPSAN-RCA-INST-001 — Initial physical-truth installer timeout

- **Symptom:** topology was not regenerated within the installer timeout.
- **Root cause:** collector payload did not have executable permission in the first package revision.
- **Corrective action:** safe rollback, permission correction and revised install/native verification.
- **Status:** `RESOLVED / PASS`.

## INPSAN-RCA-DASH-003 — Removed disk displayed healthy in disk operations

- **Root cause:** operational disk health did not consume the physical-Bay missing state.
- **Corrective action:** unify physical missing/removed state with disk operations health.
- **Status:** `RESOLVED / PASS` in v3.2.4.4-r2.

## INPSAN-RCA-ZFS-001 — Pool/VDEV identity unknown

- **Root cause:** incomplete device-path and persistent-WWN correlation.
- **Corrective action:** live ZFS leaf identity correlation.
- **Status:** `RESOLVED / PASS` in v3.2.4.5.

## INPSAN-RCA-IO-001 — I/O telemetry not sufficiently current

- **Root cause:** the main 60-second monitoring cadence was unsuitable for current operations.
- **Corrective action:** independent read-only 10-second Live I/O service.
- **Status:** `RESOLVED / PASS` in v3.2.4.6 / Live I/O v3.2.0.13.

## INPSAN-RCA-ALT-001 — Physical-Bay events missing from Event Store

- **Root cause:** the long-running Alert Engine retained an older DataAdapter in memory.
- **Corrective action:** current adapter identity/reload handling and explicit physical-Bay lifecycle processing.
- **Status:** `RESOLVED / PASS` in Alert Engine v3.2.3.0-r1.

## INPSAN-RCA-RPOOL-001 — Reinserted boot-pool member remained faulted

- **Root cause:** the first clear attempt targeted a slice-qualified name that was not the pool leaf identity.
- **Corrective action:** clear the correct whole-disk leaf and run a full scrub.
- **Status:** `RESOLVED / PASS`; pool online, zero repaired bytes and zero scrub errors.

## Open RCA queue

Five active non-disk alerts remain pending classification across power, FMA, Fibre Channel and network policy. They must not be cleared, acknowledged or silenced before read-only RCA.

