# INPSan Continuation Point

Checkpoint time: `2026-08-05 23:22 +03:30`

## Immediate objective

Close the remaining Phase 1 operational-validation gaps before beginning the full API/RBAC/reporting implementation phase.

## Next execution sequence

1. Confirm the correct host and capture pre-change state.
2. Install Dashboard Corrective Stabilization v3.2.4.3.
3. Verify services, runtime data and dashboard load.
4. Run visual QA on Chrome and the agreed browser matrix.
5. Validate typography, menus, selects, focus states and widget layout.
6. Compare dashboard bay state against the operator-reported physical state, not against inferred package output.
7. Reinsert the Bay 2 `rpool` disk and verify recovery.
8. Insert disks into Bays 6 and 7 and verify correct discovery.
9. Repeat occupied-bay removal/reinsert tests.
10. Validate missing, failed, recovered and replaced state transitions.
11. Confirm alert lifecycle and stale-alert clearing.
12. Keep all outbound notification channels disabled.
13. Resolve NTP synchronization.
14. Create test report, release decision and new official checkpoint.

## Acceptance gate

v3.2.4.3 may become a baseline only after:

- installation success;
- no regression in telemetry or alerts;
- visual acceptance;
- correct physical bay reconciliation;
- completed evidence package;
- explicit approval.

## Following phase

After closure, begin Phase 2 architecture and implementation:

- REST API;
- authentication and RBAC;
- audit trail;
- reporting;
- scheduler;
- plugin boundary.
