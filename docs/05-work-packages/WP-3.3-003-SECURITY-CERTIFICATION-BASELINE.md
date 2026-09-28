# WP-3.3-003 — Security Architecture & Certification-Readiness Baseline

Status: **STARTED**  
Start date: 2026-09-28  
Parent checkpoint: **INPSAN-CP-KB-001**  
Parent security baselines:
- `docs/11-security/SECURITY_ARCHITECTURE_V1.md`
- `docs/11-security/CONTROL_PLANE_SECURITY_CONTRACT_V1.md`
- `docs/11-security/SECURITY_HARDENING_BASELINE.md`

## Objective

Convert the INPSan 3.3 security-by-design decision into a version-bound evaluation foundation suitable for product engineering, AFTA laboratory preparation and Common-Criteria-oriented evidence.

This work package does not claim certification, Protection Profile conformance, EAL level or laboratory acceptance. Those claims require explicit confirmation against the assigned laboratory and evaluated release.

## Scope

### A. Evaluation boundary
- define the draft TOE boundary;
- classify TOE components, TOE interfaces and operational-environment dependencies;
- keep customer payload content outside management-plane evaluation logic unless an explicit evaluation requirement brings it into scope;
- distinguish INPSan proprietary security functions from upstream platform capabilities.

### B. Protection Profile applicability
- evaluate current Common Criteria PP/cPP families for relevance;
- do not force conformance to an unrelated storage-encryption or network-device PP;
- document reusable requirements from relevant profiles;
- keep final PP/conformance decision open until laboratory/product-category confirmation.

### C. Security Problem Definition
- define assets;
- threats;
- organizational security policies;
- operational-environment assumptions;
- security objectives for TOE and environment.

### D. Security Target foundation
Create a version-bound ST skeleton covering:
- TOE overview and boundary;
- interfaces and deployment;
- conformance claims;
- SPD;
- security objectives;
- selected SFR families;
- assurance target;
- TOE Summary Specification;
- evaluation evidence mapping.

### E. Standards alignment
Maintain traceability to:
- ISO/IEC 15408 / CC:2022 and CEM:2022;
- ISO/IEC 27040:2024;
- NIST SP 800-209 final;
- NIST SP 800-209 Rev.1 IPD as forward-looking guidance only;
- OWASP ASVS 5.0 Level 2 plus selected Level 3 controls for high-impact administration;
- OWASP WSTG;
- OWASP API Security Top 10;
- NIST SSDF SP 800-218;
- NIST SP 800-115;
- NIST SP 800-63B-4 for authentication guidance.

## Deliverables

1. `TOE_BOUNDARY_V0.1.md`
2. `PP_APPLICABILITY_ANALYSIS_V0.1.md`
3. `SECURITY_PROBLEM_DEFINITION_V0.1.md`
4. `SECURITY_TARGET_SKELETON_V0.1.md`
5. Security requirements/evidence matrix integrated with Roadmap 3.3
6. Laboratory-confirmation checklist before evaluation freeze

## Constraints

- no claim that INPSan is a new OS or OmniOS fork;
- no change to accepted 3.2.x storage data path under this work package;
- no production state-changing Control Plane endpoint before AuthN/RBAC/audit/TLS/input-validation gates pass;
- no unverified security control marked PASS;
- no secret, private production address, raw production log or private hardware identifier committed to this public repository;
- outbound notification channels remain disabled until separately accepted.

## Acceptance criteria

WP-3.3-003 may move from STARTED to DESIGN-BASELINE only when:
- TOE boundary is internally coherent and versioned;
- PP applicability has an explicit rationale and no unsupported conformance claim;
- SPD threats/policies/assumptions trace to security objectives;
- ST skeleton identifies the intended SFR families and unresolved laboratory decisions;
- Roadmap 3.3 workstreams can be traced to evaluation requirements;
- evidence requirements are defined for each security claim.

It may move to IMPLEMENTATION-READY only after the Control Plane security architecture and test/evidence plan are consistent with these artifacts.
