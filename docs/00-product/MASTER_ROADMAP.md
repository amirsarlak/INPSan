# INPSan Master Roadmap

Roadmap status: `ACTIVE — KNOWLEDGE-BASED, SECURITY-CERTIFICATION & PRODUCT-IDENTITY REBASELINE`  
Last review: `2026-09-28`

## Decision

INPSan will be governed through **two macro stages**. The former six-phase roadmap is retained as internal workstreams, but it is no longer the top-level delivery model.

This is not a restart. The existing storage, telemetry, dashboard, hardware-health and alerting work is carried forward as the validated technical foundation of Stage 1.


## 2026-09-28 Strategic Overlay — Knowledge-Based, Security-Certification and Product Identity

This overlay is mandatory across both macro stages and does not invalidate already accepted technical baselines.

### A. Bespoke enterprise UX and design provenance

INPSan UI/UX must be visibly and demonstrably product-specific rather than a generic dashboard skin.

- establish an INPSan-owned Design System with documented components, spacing, typography, states, interaction rules and accessibility criteria;
- define operator personas and workflows for Storage Administrator, Infrastructure Engineer, NOC/SOC Operator, IT Manager and Auditor;
- derive monitoring, alerting, logging and reporting views from real operational workflows and the team's long-term enterprise-storage and infrastructure experience;
- retain design rationale, usability-test evidence, version history and component ownership so the company can demonstrate how and why the interface was designed;
- avoid generic decorative UI patterns that reduce information density or obscure operational context;
- AI-assisted engineering tools may be used internally, but product ownership must be demonstrated through company-owned requirements, architecture, source, tests, design system and decision records rather than claims about the tool used to draft code or UI.

### B. Experience-driven observability and operational intelligence

Monitoring and alerting must be designed around actual enterprise-storage failure modes and operational questions:

- capacity, latency, IOPS, throughput, queueing and workload-pattern visibility;
- pool/dataset/LUN, FC/iSCSI, HBA, SMART, FMA, network and hardware-health correlation;
- physical-to-logical disk/chassis mapping;
- event timeline, incident context, root-cause evidence and operator-oriented remediation context;
- audit, compliance and executive/management reporting;
- configurable severity, thresholds, maintenance windows, suppression and escalation policies.

The product must preserve evidence that each important alert/report answers a defined operational or security need.

### C. Security-certification readiness (AFTA/Common-Criteria-oriented engineering)

Security certification readiness is a product-design requirement, not a final paperwork activity.

- define and version the Target of Evaluation (TOE) boundary for each certifiable release;
- maintain a Security Target package containing product scope, security functions, assumptions, threats, objectives, interfaces and deployment model;
- map security functions to an ISO/IEC 15408 / Common Criteria-oriented control matrix and tailor it to the current instructions of the assigned evaluation laboratory;
- implement auditable identification/authentication, RBAC, session security, trusted management channels, security audit, reliable time, cryptographic controls, secure configuration and protection of security-relevant state;
- signed packages and updates, integrity verification, rollback controls, secrets management, certificate lifecycle and secure defaults;
- vulnerability management, SAST/DAST/dependency scanning, SBOM, penetration testing and reproducible security evidence;
- hardening guidance for OmniOS/SMF, management-plane isolation and storage-protocol security;
- keep certification artifacts version-bound so changes to the evaluated release are traceable.

Exact AFTA protection profiles, evaluation level and laboratory instructions must be confirmed for the selected product category before certification freeze.

### D. Passive-defense and cyber-resilience alignment

INPSan shall explicitly support resilience-oriented operational requirements:

- continuous asset, health, threat and vulnerability visibility;
- monitoring, detection, warning and readiness reporting;
- continuity-oriented health indicators and evidence for BCP/DRP/incident response;
- rapid recovery, backup/restore verification and controlled degradation/fail-safe behavior;
- dependency visibility, redundancy state and single-point-of-failure reporting;
- insider-risk-relevant auditability and privileged-operation traceability;
- operational readiness reports suitable for critical, sensitive and important infrastructure environments.

### E. Per-user and per-organization customizable operations workspace

- role-aware dashboards and saved views;
- user-selectable widgets, layouts, time ranges, filters and drill-downs;
- organization-specific alert thresholds and policy profiles;
- custom report templates and scheduled reports;
- NOC/SOC/Storage/Management/Audit view presets;
- configuration inheritance with administrator-controlled policy locks;
- exportable and auditable dashboard/report definitions.

### F. Local Predictive Intelligence Engine

Predictive capability must be local-first and must not require cloud telemetry disclosure.

Architecture target:

- local time-series telemetry store and feature store;
- feature extraction from storage I/O, latency, queue depth, capacity growth, SMART/media errors, temperature, HBA/FC counters, network errors, ARC/memory pressure, alert/event history and workload seasonality;
- deterministic baselines plus anomaly detection and forecasting before introducing higher-risk supervised prediction;
- model registry, model/version provenance, confidence score, explainable contributing signals and drift monitoring;
- prediction-to-alert workflow with explicit distinction between observed fault, anomaly, forecast and recommendation;
- privacy-by-design: analyze operational telemetry/metadata by default, not customer payload content;
- false-positive/false-negative measurement and acceptance gates before a model is allowed to create operational warnings.

The predictive subsystem should be independently serviceable and is expected to introduce a dedicated analytics runtime (likely Python/ONNX-compatible) without forcing the rest of the product to migrate from its validated implementation languages.

### G. Central Management and fleet control

A centralized management plane is a strategic product capability for organizations operating multiple INPSan nodes.

- secure node enrollment and identity;
- mTLS or equivalent authenticated node-to-manager channels;
- inventory, health, alert and capacity aggregation;
- centralized configuration/policy orchestration with local safety guards;
- RBAC, tenant/site scopes and complete audit trail;
- fleet-wide reporting, maintenance windows and lifecycle visibility;
- staged/signed update orchestration with rollback and failure containment;
- resilience to Central Manager outage: storage service and safe local management must continue.

### H. Maintainable source and low key-person dependency

All proprietary code must follow an enforceable engineering-documentation standard:

- module/file header: purpose, owner, inputs/outputs, security impact and related ADR;
- public function/module contracts and meaningful docstrings;
- rationale comments for non-obvious algorithms and workarounds;
- architecture and dependency maps;
- automated unit/integration/regression tests;
- source versioning and code review;
- generated API/CLI reference where practical;
- onboarding/runbook documentation sufficient for a qualified engineer to maintain the module without relying on one individual.

Comments must explain **why** and operational/security intent, not mechanically restate obvious code.

### I. Performance engineering and resource-efficiency benchmarks

Every production service must have a measured performance envelope.

Measure at minimum:

- CPU and memory/ARC overhead;
- storage I/O overhead introduced by telemetry/history;
- event and alert processing latency;
- dashboard/API response latency (including percentile metrics);
- telemetry sample success/freshness;
- history-retention storage growth;
- startup/recovery time;
- predictive-engine inference cost;
- Central Manager scale characteristics.

Benchmark profiles must cover idle, normal, high-I/O, degraded/failure and long-duration soak conditions. Destructive or intrusive workloads are restricted to test environments.

### J. Knowledge-based evaluation evidence

For every proprietary module, maintain:

- module boundary and upstream/third-party dependencies;
- source ownership;
- implementation status;
- measurable complexity indicators;
- test plan and results;
- version/release lineage;
- RCA/ADR history;
- demo scenario;
- screenshots/diagrams with sensitive information removed;
- evidence mapping to the knowledge-based software questionnaire.

Only implemented and demonstrable capabilities may be presented as current product technology; roadmap items must remain clearly identified as future R&D.


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
- product-specific, role-aware and per-user customizable operations workspace;
- saved dashboard/report views, policy-bound customization and scheduled reports;
- authentication and session security;
- enterprise RBAC;
- audit trail;
- asynchronous jobs and scheduler;
- report generation;
- configuration and secrets management;
- explicit removal or contractual containment of napp-it redistribution/bundling dependency.

## Workstream 1.3 — Hardening, security assurance and certification readiness

- define the certifiable TOE boundary and Security Target package;
- maintain an ISO/IEC 15408 / Common-Criteria-oriented security requirements and evidence matrix, tailored to assigned AFTA laboratory instructions;
- OmniOS/SMF host hardening;
- management-plane isolation;
- TLS and certificate lifecycle;
- web/API controls aligned to OWASP ASVS 5.0 Level 2;
- secure software development aligned to the current final NIST SSDF baseline;
- storage-protocol security, FC zoning/LUN masking and iSCSI authentication policy;
- secure update, package signing, SBOM and dependency scanning;
- backup/restore, incident-response and evidence-based security verification;
- cyber-resilience, continuity, readiness, vulnerability-reduction and passive-defense-oriented operational reporting.

Hardening is a permanent cross-cutting workstream, not a final-stage activity.

## Workstream 1.4 — Licensing and product governance

- third-party license inventory and SBOM;
- explicit separation of CDDL/open-source components and proprietary INPSan components;
- napp-it bundling decision: commercial agreement or technical independence;
- signed offline-capable INPSan entitlement format;
- node/site licensing and rehost workflow;
- non-destructive expiry and grace-period behavior;
- EULA, support policy, release policy and security-update policy.

## Workstream 1.5 — GA operations, maintainability and performance engineering

- reproducible build and installation package;
- enforce source-code documentation, module contracts, rationale comments, code review and test evidence;
- establish resource-efficiency benchmarks and service performance budgets;
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
- authenticated/encrypted node-to-manager channels;
- role/site scoped administration and audit;
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

## Workstream 2.4 — Local Predictive Intelligence and analytics

- local-first telemetry/feature store with no required cloud disclosure;
- deterministic baselines and workload profiling;
- anomaly detection;
- capacity and saturation forecasting;
- failure-risk estimation from multi-source operational telemetry;
- explainable predictions with contributing signals and confidence;
- model registry, versioning and drift monitoring;
- false-positive/false-negative acceptance metrics;
- root-cause assistance and recommendation engine;
- predictive alerts remain distinguishable from observed faults;
- digital-twin modeling only after data-quality and model-quality gates are satisfied.

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
