# INPSan Official Checkpoint — CP-3.3-FINAL-001

**Title:** Final Integrated 3.3 Baseline — Product, Knowledge-Based, Security, Passive-Defense and Execution Roadmap  
**Recorded:** 2026-09-28  
**Parents:** CP-KB-001 / CP-SEC-001 / CP-PD-001  
**Status:** APPROVED FINAL 3.3 EXECUTION BASELINE

## 1. Governing decision

All INPSan 3.3+ engineering shall progress under one integrated execution model:

1. product/technical engineering;
2. knowledge-based/R&D evidence;
3. AFTA/Common-Criteria-oriented security engineering;
4. passive-defense/cyber-resilience alignment;
5. human-owned UX and design provenance;
6. experience-driven monitoring/alerting/reporting;
7. local predictive intelligence;
8. secure Central Management;
9. maintainable source engineering;
10. benchmark/resource-efficiency engineering.

No workstream may treat these as post-development documentation tasks.

## 2. Frozen product boundary

INPSan is not a new operating system and is not a fork of OmniOS.

Foundation/upstream:
- OmniOS/illumos;
- OpenZFS;
- COMSTAR/STMF;
- standard drivers/services and declared third-party components.

INPSan proprietary product layer:
- monitoring/telemetry/history;
- hardware/inventory normalization;
- physical/logical disk mapping;
- Redfish/iLO integration;
- Event Store / Alert Engine / operations UI;
- startup/readiness policies;
- independent Control Plane;
- AuthN/RBAC/Audit;
- product-specific UX/workspace/reporting;
- predictive intelligence;
- Central Manager;
- secure update/integrity/product governance.

## 3. Evaluation foundation

Working TOE:
**INPSan Secure Storage Management Appliance — Single-Node 3.3 Evaluation Candidate**

Current evaluation strategy:
- CC:2022/CEM:2022 ST-oriented foundation;
- no unsupported PP conformance claim;
- final AFTA product category, PP and assurance target subject to assigned-laboratory confirmation;
- ISO/IEC 27040:2024 and NIST SP 800-209 as storage-security baselines;
- OWASP ASVS/WSTG/API Security + NIST SSDF/SP 800-115 for Web/API/SDLC/testing.

## 4. National security / passive-defense doctrine

Mandatory product capabilities include:
- security/health monitoring;
- detection and warning;
- readiness reporting;
- continuity/recovery;
- dependency/redundancy visibility;
- privileged-operation accountability;
- vulnerability reduction;
- early-warning/predictive operation;
- controlled degradation;
- incident and recovery evidence.

## 5. UX/product doctrine

The UI must be demonstrably company-owned and experience-driven.

Every major screen/widget/alarm/report must have:
- persona;
- operational problem statement;
- source telemetry;
- decision/use case;
- logic/rationale;
- limitations;
- test/evidence.

Per-user/per-organization customization is required while security policy remains authoritative.

## 6. Predictive Intelligence doctrine

Local-first only by default.

Development order:
Data Quality -> Baseline -> Anomaly Detection -> Forecast -> Failure-Risk -> Explainable Early Warning -> Recommendation.

Customer payload content is excluded by default.

## 7. Central Management doctrine

Central Manager is mandatory in strategic roadmap but remains outside the storage data path.

Loss of Central Manager must not stop existing local storage service or safe local administration.

## 8. Source engineering doctrine

All proprietary modules must provide:
- purpose/owner;
- inputs/outputs;
- dependencies;
- security impact;
- related ADR;
- rationale comments;
- tests;
- evidence;
- version lineage;
- benchmark where applicable.

## 9. Security implementation sequence

### Gate S0 — Evaluation Foundation
Status: PASS (design baseline)
- TOE draft
- PP applicability
- SPD
- ST skeleton
- SFR baseline

### Gate S1 — Identity/AuthN
Status: PARTIAL
- independent named identity implemented in dev line;
- runtime OmniOS evidence still required.

### Gate S2 — RBAC / Object-Scope Authorization
Status: STARTED
- capability model;
- deny-by-default;
- endpoint permission declarations;
- object/scope authorization.

### Gate S3 — Security Audit Plane
Status: OPEN
- complete actor/action/target/outcome/correlation model;
- integrity/retention/export;
- privilege/config change coverage.

### Gate S4 — Session/TLS/Secrets
Status: OPEN
- session hardening;
- TLS-only production path;
- certificate lifecycle;
- secrets isolation/rotation.

### Gate S5 — Secure Operation Broker
Status: OPEN
- no unsafe shell concatenation;
- strict schemas/allow-lists;
- protected execution boundary;
- state-changing operations auditable.

### Gate S6 — Storage Protocol Security
Status: OPEN
- FC/LUN policy;
- iSCSI auth/isolation;
- NFS/SMB secure profiles;
- unauthorized-access negative tests.

### Gate S7 — Secure Update / Supply Chain
Status: OPEN
- signed update;
- rollback/downgrade controls;
- SBOM;
- SAST/SCA/DAST/secret scan.

### Gate S8 — Security Verification / Pentest
Status: OPEN
- internal verification;
- independent penetration test;
- remediation retest;
- evaluation evidence package.

## 10. Parallel product workstreams

The following advance in parallel with security gates:
- UX Design System and customizable workspace;
- benchmark/performance framework;
- predictive data-quality foundation;
- Central Manager architecture;
- operational foundation/RCA closure;
- licensing/product governance;
- knowledge-based evidence package.

## 11. Global PASS rule

No capability is PASS unless:
1. implementation exists;
2. deterministic test passes;
3. negative/failure test exists where relevant;
4. version-bound evidence is retained;
5. security/knowledge-based/passive-defense applicability is documented;
6. no contradiction exists with frozen product/evaluation boundaries.

## 12. Production safety

- validated 3.2.x line remains frozen;
- 3.3 development does not modify accepted production data paths directly;
- no state-changing Web/API endpoint before S1-S5 security gates are accepted;
- notification channels remain disabled until separately accepted;
- high-risk H240/smrt RCA restrictions remain in force for destructive hardware tests.

## 13. Immediate continuation

Proceed with:
1. close SEC-IMP-01 evidence;
2. implement SEC-IMP-02 RBAC;
3. wire endpoint permission declarations;
4. add negative authorization tests;
5. proceed to SEC-IMP-03 audit plane.

This checkpoint supersedes prior continuation-point ordering where conflicts exist, but does not invalidate prior approved technical baselines.
