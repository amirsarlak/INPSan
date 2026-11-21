# INPSan Checkpoint — CP-20261121-ROADMAP-UI-PRODUCTIZATION

## Title

Roadmap Rebaseline — UI Completion, Product Independence, Upgrade and HBA Compatibility

## Date

2026-11-21

## Decision

The INPSan roadmap is rebaselined around completion of the productized single-node appliance before lower-priority enterprise expansion.

The following are now the primary execution priorities:

1. complete the INPSan visual shell on the login page and all product pages;
2. complete and correct navigation menus;
3. complete and correct the dashboard;
4. complete the page and menu color system;
5. complete licensing, intellectual-property and third-party governance;
6. reduce and formally contain napp-it dependency;
7. implement signed upgrade, update, rollback and configuration-restore capability;
8. validate newer HBA families, including SN1100-class cards.

## Functional roadmap correction

Monitoring, reporting, snapshot management and replication are now explicit roadmap workstreams rather than scattered references:

- Monitoring and observability: Stage 1 product workstream.
- Operational and management reporting: Stage 1 product workstream.
- Snapshot, backup and restore management: Stage 1 product workstream.
- Replication and disaster recovery: Stage 2 workstream after Single-Node GA.

## Baseline carried forward

The existing technical foundation remains valid and is not discarded:

- OmniOS r151054;
- OpenZFS and COMSTAR/STMF;
- Monitoring Foundation;
- dashboard and historical telemetry;
- HPE H240/smrt inventory;
- iLO/Redfish;
- 24-bay physical topology;
- Alert Engine and Event Store;
- persistent disk identity and pool-candidate inventory;
- live release 3.3.0-r3-r9 with verified_live topology.

## Stage 1 acceptance direction

Single-Node GA requires:

- approved INPSan visual and navigation baseline;
- traceable monitoring and reporting;
- tested snapshot and restore workflow;
- authentication, RBAC, audit, TLS and secrets controls;
- supported HBA compatibility evidence;
- resolved or contractually contained napp-it dependency;
- licensing and intellectual-property records;
- signed update, rollback and configuration restore;
- documented hardware, security and operational evidence.

## Safety boundaries

- No automatic pool creation, destruction, clear, replace or export.
- No automatic fmadm acquit or repaired action.
- No notification activation without explicit acceptance.
- No raw production serial inventory or secrets in this public repository.
- No PASS or GA claim without evidence.

## Continuation point

Execution starts with the Design System and product-page inventory, followed by login shell, menus, shared color/theme system and dashboard completion. The next implementation gate is a UI/Productization evidence checkpoint, after which licensing, napp-it independence, upgrade/rollback and HBA/SN1100 compatibility work proceed in controlled branches.

This checkpoint supersedes the previous roadmap ordering while preserving all accepted technical baselines.
