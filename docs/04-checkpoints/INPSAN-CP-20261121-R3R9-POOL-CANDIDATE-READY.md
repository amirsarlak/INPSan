# INPSan Checkpoint — CP-20261121-R3R9

## Title

Topology, Dashboard Tooltip and Pool Candidate Inventory — Stable Baseline

## Acceptance status

**ACCEPTED — LIVE OPERATIONAL BASELINE**

This checkpoint records the live validation completed on 2026-11-21. Exact hardware serial inventories remain in the private evidence record and are intentionally redacted from this public repository.

## Active baseline

- INPSan release: `3.3.0-r3-r9`
- OmniOS baseline: `r151054`
- Topology schema: `1.1`
- Mapping quality: `verified_live`
- Chassis: 24-SFF, three 8-bay boxes
- Box derivation:
  - Bays 1–8: Box 1
  - Bays 9–16: Box 2
  - Bays 17–24: Box 3

## Live evidence

Topology:

```text
version=3.3.0-r3-r9 schema=1.1 chassis=1 disks=4 unassigned=0
INPSan Storage Chassis bays=24 present=4 healthy=4 warning=0 critical=0 mapping=verified_live
```

ZFS:

```text
all pools are healthy
rpool: ONLINE
```

The live appliance contains two 300 GB disks assigned to the boot mirror and two additional healthy disks, one approximately 960 GB and one approximately 1.8 TB, currently unassigned and available for a future pool.

## Accepted corrections

1. Persistent serial-to-bay reconciliation for the 24-SFF chassis.
2. Deterministic Box derivation from the global bay number.
3. Dashboard schematic tooltip now consumes the reconciled topology record.
4. Tooltip controller display is normalized to `HPE H240 / smrt` when the native source omits a controller label.
5. Tooltip data no longer depends on stale historical hot-plug events.
6. Current, enumerated disks outside active pools are exposed as pool candidates.
7. Historical napp-it `removed` state does not disqualify a currently present and enumerated free disk.
8. Active pool members remain excluded from pool-candidate inventory.
9. Installation and reconciliation remain non-destructive: no pool creation, import, clear, replace, labelclear, format or controller reset is performed automatically.

## Safety decisions

- No new pool was created by this checkpoint.
- No automatic `fmadm acquit` or `fmadm repaired` action was executed.
- The boot mirror remains protected.
- The free 960 GB and 1.8 TB disks are not members of a pool.
- A mirror between unequal capacities is not recommended.

## Remaining validation

- Select the intended pool layout before creating storage.
- Complete a documented add/remove/reinsert lifecycle test after the H240/smrt driver-risk review.
- Keep exact production hardware identifiers in private evidence only.
- Update the baseline register and release history with the r3-r9 package and this checkpoint.
- Do not declare Single-Node GA until the Stage 1 exit gate is satisfied.

## Next approved action

Choose one of:

1. independent pool for the approximately 960 GB disk;
2. independent pool for the approximately 1.8 TB disk; or
3. add same-size disks for a suitable mirror or RAIDZ layout.

This checkpoint is the continuation point for pool design, disk lifecycle acceptance and the Stage 1 productization roadmap.
