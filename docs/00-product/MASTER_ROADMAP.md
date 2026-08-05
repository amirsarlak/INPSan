# INPSan Master Roadmap

Roadmap status: `APPROVED — TWO-STAGE STRATEGIC REBASELINE`  
Last review: `2026-08-06`

## Decision

INPSan will be governed through **two macro stages**. The former six-phase roadmap is retained as internal workstreams, but it is no longer the top-level delivery model.

This is not a restart. The existing storage, telemetry, dashboard, hardware-health and alerting work is carried forward as the validated technical foundation of Stage 1.

---

# Stage 1 — Secure Single-Node Productization and General Availability

Status: `IN PROGRESS`

Estimated maturity:

- storage/monitoring technical foundation: approximately `90–95%`;
- complete Stage 1 productization scope: approximately `55–65%` because security, independent control plane, licensing and GA operations remain incomplete.

## Objective

Deliver a supportable, secure and licensable **single-node INPSan appliance/product** that can be installed, operated, upgraded, backed up and recovered without depending on undocumented manual procedures.

## Workstream 1.1 — Close the current operational foundation

- validate Dashboard Corrective Stabilization v3.2.4.3;
- complete deterministic disk-to-bay reconciliation;
- execute remove/reinsert/new-disk and failed/recovered-state tests;
- resolve NTP synchronization;
- close visual/browser regression testing;
- keep notification channels disabled until explicit acceptance.

## Workstream 1.2 — Independent INPSan control plane

- versioned REST API;
- authentication and session security;
- enterprise RBAC;
- audit trail;
- asynchronous jobs and scheduler;
- report generation;
- configuration and secrets management;
- explicit removal or contractual containment of napp-it redistribution/bundling dependency.

## Workstream 1.3 — Hardening and security assurance

- OmniOS/SMF host hardening;
- management-plane isolation;
- TLS and certificate lifecycle;
- web/API controls aligned to OWASP ASVS 5.0 Level 2;
- secure software development aligned to the current final NIST SSDF baseline;
- storage-protocol security, FC zoning/LUN masking and iSCSI authentication policy;
- secure update, package signing, SBOM and dependency scanning;
- backup/restore, incident-response and evidence-based security verification.

Hardening is a permanent cross-cutting workstream, not a final-stage activity.

## Workstream 1.4 — Licensing and product governance

- third-party license inventory and SBOM;
- explicit separation of CDDL/open-source components and proprietary INPSan components;
- napp-it bundling decision: commercial agreement or technical independence;
- signed offline-capable INPSan entitlement format;
- node/site licensing and rehost workflow;
- non-destructive expiry and grace-period behavior;
- EULA, support policy, release policy and security-update policy.

## Workstream 1.5 — GA operations

- reproducible build and installation package;
- upgrade and rollback paths;
- configuration backup/restore;
- support bundle with sensitive-data filtering;
- hardware compatibility matrix;
- operational runbooks;
- release signing and checksums;
- acceptance and soak testing.

## Stage 1 exit gate

Stage 1 is complete only when:

1. the single-node product has no unresolved critical operational defect;
2. disk/bay identity and failure/recovery tests pass;
3. authentication, RBAC, audit, TLS and secrets handling pass security acceptance;
4. license and third-party redistribution risks are resolved;
5. upgrade, rollback and configuration restore are demonstrated;
6. the product can continue serving existing data safely if a commercial license expires;
7. documentation, compatibility matrix and signed release artifacts are complete;
8. an official **INPSan Single-Node GA** checkpoint is approved.

---

# Stage 2 — Enterprise Scale, Automation and Ecosystem

Status: `PLANNED`

## Objective

Expand the Stage 1 appliance into a centralized, multi-node and multi-site **Enterprise Storage Platform**.

## Workstream 2.1 — Centralized and multi-node management

- secure node enrollment;
- central manager;
- organization/site/cluster/storage hierarchy;
- federated monitoring and incident view;
- fleet configuration and lifecycle management;
- HA-aware control-plane design.

## Workstream 2.2 — Automation and orchestration

- workflow engine;
- policy engine;
- scheduled and event-driven jobs;
- maintenance mode and suppression;
- approval-gated remediation;
- ticketing and integration adapters.

## Workstream 2.3 — Replication and resilience management

- policy-based snapshot and replication management;
- topology-aware failover/failback workflows;
- RPO/RTO reporting;
- DR testing and evidence;
- cluster/site licensing.

## Workstream 2.4 — Analytics and prediction

- anomaly detection;
- capacity forecasting;
- failure-risk estimation;
- root-cause assistance;
- recommendation engine;
- digital-twin modeling only after data-quality gates are satisfied.

## Workstream 2.5 — Ecosystem and hybrid cloud

- VMware, Hyper-V and Proxmox integrations;
- Kubernetes/OpenShift integration;
- backup ecosystem integration;
- cloud connectors;
- plugin/SDK governance.

## Stage 2 exit gate

Stage 2 is complete when centralized control, automation, multi-site resilience and ecosystem integrations meet defined scalability, HA, security and supportability targets.

---

# Final destination

**INPSan Enterprise Storage Platform** with:

- unified management;
- secure and scalable architecture;
- automation-driven operations;
- multi-node and multi-site control;
- AI-assisted insights;
- hybrid-cloud readiness;
- enterprise-grade reliability and supportability.
