# ADR-0004 — Persistent Disk Identity and Physical Bay Mapping

Status: `ACCEPTED / OPERATIONAL VALIDATION PENDING`

## Context

Device paths and controller enumeration can change after reboot, rescan, disk removal or reinsertion. A storage-management UI must identify both the logical disk and its physical bay reliably.

## Decision

Use a reconciliation model combining:

- persistent disk identity such as WWN/serial where available;
- controller and enclosure relationship;
- physical enclosure and slot number;
- last-known state with freshness and conflict handling.

Transient device path may be displayed as diagnostic data but must not be the sole identity key.

## Consequences

- a reconciliation layer is required;
- duplicate/conflicting identities must be detected;
- empty, missing, failed, reinserted and replaced states need explicit transitions;
- removal/reinsert/addition acceptance tests are mandatory.

## Validation state

Architecture accepted. Complete operational acceptance across the current front-bay test plan remains pending.
