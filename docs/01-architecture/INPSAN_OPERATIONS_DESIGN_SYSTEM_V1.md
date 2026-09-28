# INPSan Operations Design System (IODS) v1.0

Status: **DESIGN FOUNDATION**  
Date: 2026-09-28

## 1. Purpose

IODS defines a product-specific operational UX derived from enterprise storage and infrastructure workflows. The goal is not decorative differentiation; it is faster and safer operational decision-making with traceable design rationale.

## 2. Primary personas

### Storage Administrator
Needs pool/dataset/LUN/FC/iSCSI, disk identity, IOPS/throughput/latency, capacity, physical mapping and safe remediation context.

### Infrastructure Engineer
Needs server/HBA/NIC/power/fan/temperature/firmware/health and dependency visibility.

### NOC/SOC Operator
Needs prioritized incidents, event timeline, correlation, security/availability context and escalation state.

### IT Manager
Needs capacity risk, availability, trends, SLA-oriented summaries, forecast and management reports.

### Auditor
Needs immutable/auditable events, access/configuration history, evidence exports and compliance-oriented views.

## 3. Operational design rules

- current critical state is visually dominant;
- every severe alert exposes evidence and affected entity;
- physical and logical identity are shown together where relevant;
- color is never the only carrier of severity;
- dense operational data is allowed when it reduces drill-down time;
- decorative elements must not displace operational information;
- destructive actions require explicit confirmation and authorization context;
- recommendations are visually distinct from observed facts;
- observed fault, anomaly, forecast and recommendation use different semantic states.

## 4. Workspace customization

Users may save:
- widget selection/layout;
- filters and time ranges;
- entity scopes;
- table columns/sorts;
- report templates;
- NOC/SOC/Storage/Manager/Audit presets.

Administrators may enforce policy-locked content such as critical security/availability alerts and mandatory compliance widgets.

## 5. Design provenance

Each major screen/workflow must retain:
- persona/problem statement;
- operational question answered;
- information hierarchy rationale;
- source data contract;
- security constraints;
- usability/acceptance evidence;
- version/change history.

## 6. Initial 3.3 screens

1. Executive/Operations Overview.
2. Storage & Capacity.
3. Physical Chassis & Disk Identity.
4. Performance & Workload.
5. Alerts / Incidents / Event Timeline.
6. Security & Audit.
7. Reports.
8. Administration / Policies.
9. Future Predictive Intelligence.
10. Future Fleet/Central Management.

## 7. Acceptance gate

No broad visual rewrite is accepted before persona/workflow mapping and component tokens are reviewed. Existing 3.2.x operational data contracts must remain functional while the 3.3 presentation layer evolves.