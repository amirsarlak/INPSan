# INPSan Master Roadmap

Roadmap status: `ACTIVE — PRODUCTIZATION, UI COMPLETION, STORAGE OPERATIONS AND GA`
Last rebaseline: `2026-11-21`
Source of truth: `amirsarlak/INPSan`

## 1. Product decision

INPSan is governed through two macro stages:

1. **Stage 1 — Complete, secure and supportable Single-Node product**
2. **Stage 2 — Enterprise scale, automation, replication and ecosystem**

The existing storage, telemetry, dashboard, hardware-health and alerting work is retained as the technical foundation. The project is not restarted; the roadmap is reordered so that product identity, usability, independence and operational completeness are delivered before expansion.

## 2. Product destination

INPSan must become an independently supportable enterprise storage platform for OmniOS, OpenZFS and COMSTAR/STMF with:

- product-specific GUI and design system;
- reliable storage, hardware and service monitoring;
- operational dashboards and management reports;
- alert/event lifecycle and auditability;
- snapshot, backup and restore management;
- replication and disaster-recovery workflows;
- secure upgrade and rollback;
- licensing and intellectual-property governance;
- hardware compatibility and HBA support;
- later multi-node, automation and analytics capabilities.

## 3. Current validated foundation

The following foundation is implemented or validated in the project record:

- OmniOS `r151054`;
- OpenZFS and COMSTAR/STMF foundation;
- Web GUI baseline;
- Monitoring Foundation and SMF services;
- CPU, memory/ARC, network, storage I/O and historical telemetry;
- SMART, HBA, PCI and hardware-health inventory;
- HPE iLO/Redfish integration;
- HPE H240/`smrt` recognition;
- physical 24-bay topology visualization;
- Alert Engine and Event Store;
- alert presentation and lifecycle history;
- accessibility/readability corrections;
- FC and iSCSI foundations;
- persistent disk identity and Serial-to-Bay reconciliation;
- pool-candidate inventory for present, enumerated disks outside active pools.

Latest live checkpoint:

- INPSan `3.3.0-r3-r9`;
- topology schema `1.1`;
- mapping `verified_live`;
- 24-SFF chassis with three 8-bay boxes;
- four healthy disks visible;
- `rpool` online and healthy;
- approximately 960 GB and 1.8 TB disks available as unassigned pool candidates.

## 4. Locked execution priority

The following order is now the active execution priority before lower-priority roadmap expansion.

### P0.1 — Complete INPSan visual shell and brand identity

Scope:

- complete login-page shell;
- replace remaining generic or inherited visual surfaces;
- establish INPSan design tokens;
- unify header, footer, panels, cards, dialogs, tables, forms and notifications;
- define typography, spacing, borders, icons, focus states and responsive behavior;
- preserve accessibility and readable high-contrast states;
- document component ownership and visual rules.

Acceptance:

- login and all major pages use a coherent INPSan-owned shell;
- no page visibly falls back to an inconsistent legacy theme;
- desktop and supported browser regression checks pass.

### P0.2 — Complete and correct navigation menus

Scope:

- normalize primary navigation;
- complete Pools, Disks, Monitoring, Reports, Snapshots, Replication, Services, System, Security and Administration sections;
- remove dead, duplicate and misleading menu items;
- define role-aware visibility;
- ensure breadcrumbs, back navigation, active states and deep links are consistent;
- preserve safe confirmation for destructive actions.

Acceptance:

- every visible menu item resolves to a supported page or documented controlled placeholder;
- no orphaned or contradictory navigation remains;
- menu behavior is validated at supported browser zoom levels.

### P0.3 — Complete and correct the dashboard

Scope:

- executive health summary;
- storage and pool overview;
- disk and physical topology view;
- live I/O;
- monitoring freshness and readiness;
- alert and incident summary;
- hardware/FMA/iLO/HBA status;
- network and protocol status;
- capacity and trend panels;
- operational drill-downs;
- user-selectable widgets and saved views;
- clear separation between observed facts, warnings, predictions and recommendations.

Acceptance:

- dashboard values are traceable to an authoritative source;
- stale, missing and unverified values are explicitly labelled;
- no synthetic health value is presented as measured truth;
- all major cards have usable drill-down paths.

### P0.4 — Complete page and menu color system

Scope:

- common color tokens for healthy, warning, critical, offline, disabled, selected and informational states;
- login, menus, forms, tables, tooltips, alerts, modal dialogs and dashboard surfaces;
- light/dark or approved theme behavior;
- contrast and focus validation;
- browser-specific rendering checks.

Acceptance:

- no dark-text-on-dark-background defect;
- state colors are semantically consistent across the product;
- color is not the sole carrier of critical meaning.

### P0.5 — Licensing and intellectual-property governance

Scope:

- define INPSan-owned versus third-party components;
- establish product LICENSE;
- generate THIRD_PARTY_NOTICES and SBOM;
- document CDDL/OpenZFS and OmniOS obligations;
- resolve napp-it redistribution/bundling rights;
- document ownership of source, UI, design system, schemas and documentation;
- define EULA, support policy, privacy/telemetry statement and security-update policy;
- define evidence and approval responsibilities.

Acceptance:

- every shipped component has a recorded license and provenance;
- no unapproved proprietary napp-it material is redistributed;
- release approval includes legal/product/engineering sign-off.

### P0.6 — Reduce napp-it dependency

Scope:

- inventory every runtime dependency on napp-it;
- separate INPSan-owned data, API, UI, services and configuration;
- create native INPSan adapters for disk, pool, dataset, service, snapshot and hardware inventory;
- replace direct legacy-page dependence where practical;
- define contractual containment for unavoidable transitional dependencies;
- provide migration and rollback boundaries.

Acceptance:

- INPSan can operate its core monitoring, inventory, alerting and reporting without undocumented napp-it behavior;
- remaining dependencies are explicit, versioned and tested;
- long-term target is technical independence or a formally approved commercial route.

### P0.7 — Upgrade, update and rollback capability

Scope:

- signed and checksum-verified packages;
- preflight, dry-run, install, verify and rollback commands;
- versioned manifest and migration steps;
- configuration backup and restore;
- preservation of Event Store, Audit, Controls and notification policy;
- safe service restart and dependency ordering;
- failed-update recovery;
- offline update support;
- release notes and operator runbook.

Acceptance:

- update from the current accepted baseline succeeds;
- rollback restores the previous working baseline;
- data-plane services and existing pools remain safe;
- update does not silently alter storage layout or activate notifications.

### P0.8 — HBA compatibility, including newer cards such as SN1100

Scope:

- define supported HBA models, firmware, driver and mode matrix;
- validate SN1100 and other target HBA families;
- cover FC initiator/target behavior, port state, WWN discovery, zoning/LUN visibility and fail/recovery;
- distinguish required and optional ports;
- capture driver/kernel/firmware compatibility;
- add HBA evidence to topology, alerting and readiness;
- document unsupported configurations and safe fallback behavior.

Acceptance:

- supported HBA appears correctly in inventory;
- required FC path is correctly classified;
- optional disconnected ports do not create false critical alerts;
- no HBA test compromises existing pools or data services.

## 5. Stage 1 operational workstreams

### W1 — Monitoring and observability

Status: foundation implemented; product completion pending.

Deliver:

- health, capacity, latency, IOPS, throughput and queue visibility;
- pool, dataset, LUN, disk, HBA, FC/iSCSI, SMART, FMA, network and hardware correlation;
- physical-to-logical identity mapping;
- freshness, completeness and readiness contracts;
- event timeline and incident context;
- maintenance windows, thresholds, suppression and escalation policies;
- historical retention and export;
- support bundle with sensitive-data filtering.

### W2 — Reporting

Status: planned/incomplete as a product capability.

Deliver:

- operational report templates;
- storage capacity and growth reports;
- pool/dataset/LUN and disk-health reports;
- alert, incident, audit and change reports;
- hardware and compatibility reports;
- executive/NOC/SOC/Storage/Audit views;
- scheduled reports;
- PDF/CSV/JSON export where appropriate;
- role-based report access;
- report definition versioning and audit.

### W3 — Snapshot and backup management

Status: underlying platform capability exists; independent product workflow incomplete.

Deliver:

- snapshot inventory and browsing;
- policy-based schedules;
- retention and pruning policy;
- holds/locks and protected snapshots;
- dataset/pool/LUN scope;
- restore and clone workflow;
- backup/export integration;
- restore verification;
- space-impact reporting;
- permissions, approvals and audit;
- non-destructive failure behavior.

### W4 — Alerting and event operations

Status: core Alert Engine/Event Store implemented; operational hardening continues.

Deliver:

- observed-fault versus warning versus prediction distinction;
- incident deduplication and lifecycle;
- acknowledgement, silence and maintenance policy;
- current state plus preserved history;
- audit of operator actions;
- startup/readiness integration;
- notification channels disabled until channel-specific acceptance.

### W5 — Security and independent control plane

Deliver:

- versioned REST API;
- authentication and secure sessions;
- RBAC and least privilege;
- audit trail;
- CSRF/XSS/command-injection protections;
- TLS and certificate lifecycle;
- secrets management;
- management/data-plane separation;
- secure defaults and rate controls;
- security target and evidence matrix.

### W6 — Reliability, packaging and operations

Deliver:

- reproducible build and installation package;
- upgrade/rollback;
- configuration backup/restore;
- hardware compatibility matrix;
- runbooks and support procedures;
- performance budgets;
- idle, normal, high-I/O, degraded and long-duration testing;
- signed release artifacts;
- sensitive-data filtering.

## 6. Stage 1 exit gate — Single-Node GA

Stage 1 cannot be declared GA until all conditions below pass:

1. login, menus, pages and dashboard meet the approved INPSan design baseline;
2. no unresolved critical operational defect remains;
3. disk/Bay identity passes add/remove/reinsert/failure/recovery tests;
4. monitoring and reporting are traceable and complete;
5. snapshot and restore workflows are tested;
6. authentication, RBAC, audit, TLS and secrets handling pass;
7. HBA compatibility matrix passes the supported hardware target;
8. napp-it redistribution risk is resolved or contractually contained;
9. licensing and intellectual-property records are complete;
10. upgrade, rollback and configuration restore are demonstrated;
11. SBOM, third-party notices and signed release artifacts exist;
12. FMA/H240 driver-risk RCA is classified with a safe operating policy;
13. notification posture is explicitly accepted;
14. official `INPSan Single-Node GA` checkpoint is approved.

## 7. Stage 2 — Enterprise scale and resilience

Stage 2 begins only after Stage 1 GA.

### W7 — Replication and disaster recovery

Status: planned.

Deliver:

- policy-based ZFS replication;
- snapshot-to-replication integration;
- schedule, retention and bandwidth controls;
- source/target identity and authorization;
- RPO/RTO reporting;
- replication health and lag monitoring;
- failover/failback workflow;
- DR test mode and evidence;
- site/cluster licensing;
- Central Manager outage independence.

### W8 — Central Manager and multi-node

- secure node enrollment;
- mTLS or equivalent authenticated channels;
- node/site/cluster/storage hierarchy;
- federated inventory, alerts, capacity and reports;
- central policy with local safety guards;
- fleet audit and RBAC;
- staged signed updates and rollback;
- HA-aware control plane.

### W9 — Automation and orchestration

- workflow engine;
- policy engine;
- scheduled and event-driven jobs;
- approval-gated remediation;
- maintenance mode;
- ticketing and integration adapters.

### W10 — Local predictive intelligence

- local time-series and feature store;
- deterministic baselines;
- anomaly detection and forecasting;
- capacity and saturation prediction;
- explainable signals and confidence;
- model registry and drift monitoring;
- false-positive/false-negative acceptance;
- predictive alerts clearly separated from observed faults.

### W11 — Ecosystem integrations

- VMware, Hyper-V and Proxmox;
- Kubernetes/OpenShift;
- backup platforms;
- cloud connectors;
- plugin and SDK governance.

## 8. Cross-cutting governance

Every release and major work package must include:

- source commit and release lineage;
- ADR/RCA linkage;
- package hash and signature;
- upgrade and rollback path;
- test report and evidence ID;
- security and licensing impact;
- compatibility impact;
- sanitized screenshots/diagrams;
- operator documentation.

Production safety rules remain locked:

- no automatic pool destruction, clear, replace or export;
- no automatic FMA acquit/repaired;
- no silent notification activation;
- no storage mutation as a UI repair;
- no claim of PASS without evidence;
- no raw production identifiers or secrets in the public repository.

## 9. Immediate execution sequence

1. Freeze the current `3.3.0-r3-r9` live baseline.
2. Produce the INPSan Design System and page inventory.
3. Complete login shell, menus, common theme and color tokens.
4. Complete dashboard information architecture and source-of-truth mapping.
5. Add reporting, snapshot and replication sections to the GUI/API design.
6. Establish licensing/IP and napp-it dependency registers.
7. Implement signed update, rollback and configuration restore.
8. Build HBA/SN1100 compatibility branch and test matrix.
9. Re-run storage, topology, monitoring, alert, snapshot and restore acceptance.
10. Issue the next checkpoint after evidence review.

## 10. Final destination

INPSan Enterprise Storage Platform:

- product-owned user experience;
- independent and supportable control plane;
- secure single-node appliance;
- complete monitoring, reporting, snapshots and replication;
- hardware compatibility and lifecycle safety;
- multi-node and multi-site control;
- automation, analytics and ecosystem integration.
