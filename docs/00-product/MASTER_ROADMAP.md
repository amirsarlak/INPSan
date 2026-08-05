# INPSan Master Roadmap

Roadmap status: `APPROVED`  
Last review: `2026-08-05`

## Phase 1 — Operational Core and Monitoring

Overall status: `PARTIAL PASS / approximately 90–95%`

Validated scope:

- Core storage foundation;
- Web GUI;
- Monitoring Foundation;
- telemetry and history;
- dashboard visualization;
- hardware inventory and health;
- iLO/Redfish integration;
- Alert Engine and Event Store;
- dashboard alert presentation;
- accessibility/readability corrective release.

Remaining Phase 1 closure work:

- complete deterministic disk-to-bay reconciliation;
- execute full disk removal/reinsert/addition tests;
- finish current corrective dashboard validation;
- close remaining time/NTP synchronization issue;
- formally validate notification channels before activation.

## Phase 2 — API, Security and Reporting

Status: `CURRENT STRATEGIC PHASE / PROPOSED`

Scope:

- REST API;
- RBAC;
- authentication/session security;
- audit trail;
- reports;
- scheduler;
- plugin SDK;
- configuration and secrets governance.

Exit criterion: storage and observability functions can be controlled safely through a documented, versioned and audited control plane.

## Phase 3 — Centralized and Multi-node Management

Status: `PLANNED`

Scope:

- node registration;
- central manager;
- collector/agent architecture;
- federated monitoring;
- organization/site/cluster/storage hierarchy;
- multi-site health and incident view.

## Phase 4 — Automation and Orchestration

Status: `PLANNED`

Scope:

- job scheduler;
- workflow engine;
- policy engine;
- automated remediation with approval gates;
- maintenance mode and suppression;
- ticketing/webhook integrations after security review.

## Phase 5 — Analytics and Prediction

Status: `PLANNED`

Scope:

- anomaly detection;
- capacity forecasting;
- failure-risk estimation;
- root-cause assistance;
- recommendation engine;
- digital-twin modeling where sufficient data quality exists.

## Phase 6 — Hybrid Cloud and Ecosystem

Status: `PLANNED`

Scope:

- VMware, Hyper-V and Proxmox integrations;
- Kubernetes/OpenShift integration;
- backup ecosystem integration;
- cloud connectors;
- centralized fleet lifecycle management.

## Final destination

**Enterprise Storage Platform** with unified management, scalable architecture, automation-driven operations, AI-assisted insights, hybrid-cloud readiness and enterprise-grade reliability.
