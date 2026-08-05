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
- **Status:** `RESOLVED / PASS` in v3.2.1.6 baseline.

## INPSAN-RCA-HW-001 — HPE H240 not represented correctly

- **Symptom:** controller/hardware inventory was incomplete.
- **Root cause class:** driver/source recognition mismatch.
- **Corrective action:** recognize the H240 through OmniOS `smrt` and integrate native hardware inventory.
- **Status:** `RESOLVED / PASS` in v3.2.0.11-r2.

## INPSAN-RCA-DASH-002 — Low contrast and undersized UI

- **Symptom:** dark text could appear on dark menu/select surfaces; fonts remained difficult to read at 150% zoom.
- **Root cause class:** insufficiently explicit theme contrast and typography rules across controls/browsers.
- **Corrective action:** high-contrast light surfaces, dark text, larger typography and clear focus states.
- **Status:** `RESOLVED / PASS` in v3.2.3.1-r1.

## INPSAN-RCA-HW-002 — Physical bay identity ambiguity

- **Symptom:** a disk must stay associated with the correct physical bay through removal, failure and reinsertion.
- **Root cause class:** transient enumeration cannot guarantee stable logical-to-physical identity.
- **Corrective action:** persistent disk identity plus enclosure/slot reconciliation.
- **Status:** `PARTIAL PASS`; full physical acceptance testing pending.

## INPSAN-RCA-DASH-003 — Corrective stabilization not yet accepted

- **Symptom:** a consolidated package was required for remaining theme/font/widget/mapping corrections.
- **Corrective action:** v3.2.4.3 package built, hash verified and preflight passed.
- **Status:** `OPEN / AWAITING VALIDATION`; installation and browser acceptance evidence required.
