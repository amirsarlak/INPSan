# ADR-0004 — Persistent Disk Identity and Physical Bay Mapping

Status: `ACCEPTED / OPERATIONALLY VALIDATED`

## Context

Device paths and controller enumeration can change after reboot, rescan, disk removal or reinsertion. iLO does not reliably expose the H240-attached physical disks. Retained OmniOS inventory can also outlive a physical removal event.

## Decision

Use a reconciliation model combining:

- H240 `smrt` Port/Box/Bay/Serial insertion and removal events as the physical-presence truth source;
- persistent disk identity such as WWN/serial for exact expected-drive matching;
- current OmniOS device identity for runtime I/O and ZFS correlation;
- an explicit event freshness rule so a newer removal event overrides retained OS inventory;
- explicit `EMPTY`, `PRESENT`, `MISSING/REMOVED`, `FAILED`, `WRONG DRIVE` and `UNVERIFIED` states.

Transient device paths may be displayed as diagnostics but are not the sole identity key. A controller failure event emitted as part of a physical removal lifecycle is not, by itself, proof of media failure.

## Consequences

- exact expected identities can produce Critical missing-drive incidents;
- current pool/VDEV correlation remains separate from physical presence;
- historical events remain append-only;
- raw identity inventories must remain outside the public repository;
- removal, reinsertion, replacement and stale-record suppression require regression coverage.

## Validation state

Operational validation completed for boot-pool member recovery, new disks, repeated Bay 6/7 removal and reinsertion, exact expected identities, stale-record suppression and Alert/Event lifecycle.

Evidence: `INPSAN-CP-OPS-001` and `TEST-OPS-001`.

