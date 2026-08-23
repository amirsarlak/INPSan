# INPSan Current Operational State

State date: `2026-08-23 17:12 +03:30`  
Classification: `LIVE VALIDATED / SANITIZED PUBLIC SUMMARY`

## Stable operational foundation

- OmniOS r151054 and napp-it 22.03 host integration;
- Web GUI Golden v3.1.13;
- Monitoring Foundation v3.2.0.5;
- Dashboard v3.2.4.6-ui1 and DataAdapter 3.2.4.6;
- H240 topology v3.2.0.11-r3 with physical mapping quality `verified_live`;
- Live I/O v3.2.0.13 with read-only 10-second sampling;
- Alert Engine/Event Store v3.2.3.0-r1;
- Notification Engine v3.2.4.0-r1 and Notification Center v3.2.4.1 with outbound delivery disabled.

## Storage and topology state

- all pools were healthy at the final accepted checkpoint;
- the boot pool mirror was online and completed a scrub with zero repaired bytes and zero errors;
- eight disks were present and healthy in front Bays 1–8;
- Bays 9–24 were verified empty;
- the 1.8 TB disks in Bays 6 and 7 were intentionally not assigned to any ZFS pool at this checkpoint;
- disk-to-pool and VDEV correlation was live-verified for pool members.

Raw device names, WWNs and serial numbers are intentionally omitted from this public record.

## Physical-Bay lifecycle state

- H240 Port/Box/Bay/Serial events are the physical-presence truth source because iLO does not reliably expose H240-attached disks;
- current OS inventory is correlated with H240 events but cannot override a newer removal event;
- removal produces `MISSING/REMOVED` and a Critical physical-Bay alert for expected identities;
- reinsertion of the expected drive restores healthy state after configured stability cycles;
- independent Bay 6 and Bay 7 incidents were opened and resolved with append-only history.

## Dashboard and operations state

- dark-theme contrast and typography are accepted;
- disk operations are compact and responsive;
- Bay order is numeric ascending;
- capacity is visible while full identity, topology, SMART and error detail remains available through hover/focus;
- disk read, write, IOPS and busy values use the latest 10-second sample.

## Current pending actions

1. Perform read-only RCA of five active non-disk alerts.
2. Classify each as `REAL FAULT`, `EXPECTED STATE`, `POLICY ISSUE` or `FALSE POSITIVE`.
3. Correct alert rules only where evidence proves a false positive.
4. Keep outbound notification channels disabled until alert quality is accepted.
5. Conduct controlled channel-by-channel delivery tests after alert RCA.
6. Continue Stage 1 API, authentication, RBAC, audit, reporting, hardening and licensing work after operational closure.

## Protected state

Do not clear, acknowledge or silence current active alerts before RCA. Do not run FMA repair/acquit actions, modify the chassis map manually, replay historical alerts or delete Event/Audit history.

