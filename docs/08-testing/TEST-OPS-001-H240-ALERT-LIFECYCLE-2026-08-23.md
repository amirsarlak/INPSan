# TEST-OPS-001 — H240 Physical Bay and Alert Lifecycle

- Date: `2026-08-23`
- Related checkpoint: `INPSAN-CP-OPS-001`
- Evidence classification: `SANITIZED PUBLIC SUMMARY`
- Result: `PASS`

## Scope

- exact physical Bay occupancy;
- stale OS inventory suppression;
- expected-drive removal behavior;
- independent incidents for two Bays;
- reinsertion recovery;
- Event Store opened/resolved persistence;
- ZFS non-regression;
- outbound notification safety.

## Preconditions

- topology service online;
- mapping quality `verified_live`;
- all pools healthy;
- Alert Engine v3.2.3.0-r1 using DataAdapter 3.2.4.6;
- all outbound channels disabled.

## Execution summary

1. Removed the expected disk from Bay 7.
2. Confirmed physical missing state and a Critical incident.
3. Removed the expected disk from Bay 6.
4. Confirmed a second independent Critical incident.
5. Reinserted both expected disks.
6. Confirmed exact identity recovery, healthy topology and incident resolution after the configured stability cycles.
7. Confirmed append-only opened/resolved Event Store records.
8. Confirmed all pools remained healthy.

## Results

| Check | Result |
|---|---:|
| H240 physical event detection | PASS |
| Exact Bay state | PASS |
| Stale-record suppression | PASS |
| Independent Bay 6/7 Critical incidents | PASS |
| Expected identity reinsertion | PASS |
| Stable automatic resolution | PASS |
| Event history retained | PASS |
| ZFS pools healthy | PASS |
| Outbound delivery remained disabled | PASS |

## Evidence boundary

Exact serials, WWNs, device paths, raw controller logs and incident identifiers are retained in private evidence checkpoint `CP-20260823-EOC-01` and are intentionally excluded from this public repository.

