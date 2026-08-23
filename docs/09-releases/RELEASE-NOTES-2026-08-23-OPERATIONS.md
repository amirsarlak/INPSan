# INPSan Operational Acceptance Release Notes — 2026-08-23

Status: `PASS / ACCEPTED`

## Delivered

- H240 physical Bay truth with exact expected identities;
- stale retained-device suppression after physical removal;
- explicit missing/removed and recovery lifecycle;
- live ZFS pool/VDEV identity correlation;
- read-only 10-second disk I/O telemetry;
- compact responsive Disk Operations view;
- numeric Bay ordering and visible capacity labels;
- current DataAdapter reload/identity handling in Alert Engine;
- append-only physical-Bay opened/resolved incidents.

## Accepted baselines

- Dashboard `v3.2.4.6-ui1`;
- DataAdapter `3.2.4.6`;
- topology `v3.2.0.11-r3` plus map1;
- Live I/O `v3.2.0.13`;
- Alert Engine `v3.2.3.0-r1`.

## Safety and compatibility

- all pools healthy after live acceptance;
- no Notification Channel enabled;
- no historical Event/Audit records removed;
- rollback not required;
- raw production evidence excluded from the public repository.

## Known pending items

- read-only RCA of five non-disk active alerts;
- evidence-based alert policy correction if required;
- controlled Notification Channel delivery tests;
- reporting/exports and remaining Stage 1 productization work.

