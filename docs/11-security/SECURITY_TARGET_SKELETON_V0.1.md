# INPSan Security Target Skeleton v0.1

Status: **DRAFT SKELETON — NOT AN EVALUATION CLAIM**  
Date: 2026-09-28  
Parent: `WP-3.3-003`

## 1. Security Target Introduction

### 1.1 ST reference
- Product: INPSan Enterprise Storage Platform
- Candidate TOE: INPSan Secure Storage Management Appliance — Single-Node 3.3 Evaluation Candidate
- ST version: 0.1
- Evaluated release/build: TBD
- Evaluation scheme/laboratory: TBD

### 1.2 TOE reference
Exact software version, package manifest, platform build, enabled services and evaluated configuration are TBD until evaluation freeze.

### 1.3 TOE overview
INPSan is an enterprise storage productization and secure-management layer built on a supported OmniOS/OpenZFS/COMSTAR foundation. The candidate TOE focuses on proprietary management, identity/authorization, audit, secure storage-control workflows, Web/API security, secrets/certificate handling and software-integrity/update functions.

### 1.4 TOE type
Working classification:
**Secure enterprise storage management appliance / SAN-NAS management and security product layer.**

## 2. TOE Description

### 2.1 Physical scope
To be derived from:
- `TOE_BOUNDARY_V0.1.md`
- exact evaluated appliance/hardware configuration.

### 2.2 Logical scope
Candidate security functions:
1. Identification and authentication.
2. Role/function/object/scope authorization.
3. Session security.
4. Security audit and accountability.
5. Protected management communications.
6. Web/API request and input protection.
7. Secret/certificate lifecycle protection.
8. Secure storage-control authorization.
9. Secure update and integrity verification.
10. Protected recovery/configuration operations.
11. Secure defaults and selected self-protection mechanisms.

### 2.3 Non-TOE operational environment
Candidate exclusions:
- OmniOS/illumos kernel and standard drivers;
- OpenZFS implementation;
- COMSTAR/STMF implementation;
- external FC fabric and hypervisors;
- external AD/LDAP/PKI/NTP/SIEM;
- iLO firmware;
- customer payload processing;
- future Central Manager unless explicitly included.

Final placement requires laboratory confirmation.

## 3. Conformance Claims

### 3.1 Common Criteria
Target framework:
- CC:2022;
- CEM:2022.

Exact part/revision statements to be completed according to scheme/laboratory instructions.

### 3.2 Protection Profile conformance
**OPEN — no PP conformance claim in v0.1.**

See `PP_APPLICABILITY_ANALYSIS_V0.1.md`.

### 3.3 Assurance package
**TBD with assigned laboratory.**

No EAL or equivalent assurance claim is made by this skeleton.

## 4. Security Problem Definition

Normative working source:
- `SECURITY_PROBLEM_DEFINITION_V0.1.md`

This section will freeze:
- threats;
- organizational security policies;
- operational-environment assumptions.

## 5. Security Objectives

### 5.1 TOE objectives
Working set:
- O.IDAUTH
- O.AUTHZ
- O.SESSION
- O.TRUSTED_CHANNEL
- O.AUDIT
- O.AUDIT_PROTECT
- O.INPUT
- O.SECRETS
- O.SECURE_STORAGE_CONTROL
- O.UPDATE
- O.INTEGRITY
- O.RECOVERY
- O.RESOURCE
- O.SAFE_FAILURE
- O.SECURE_DEFAULT

### 5.2 Operational-environment objectives
Working set:
- OE.PHYSICAL
- OE.NETWORK
- OE.FABRIC
- OE.TIME
- OE.PKI_DIRECTORY
- OE.PLATFORM
- OE.ADMIN
- OE.EXTERNAL_BACKUP

### 5.3 Rationale
A complete objective rationale/coverage table will be generated after laboratory feedback and final TOE scope.

## 6. Extended Components Definition

Current position:
- Prefer existing CC functional components where adequate.
- Define extended components only if product-specific security requirements cannot be represented accurately with existing components.
- Any extension requires explicit rationale and evaluator review.

## 7. Security Requirements

## 7.1 Candidate Security Functional Requirement families

### FAU — Security Audit
Candidate coverage:
- audit generation;
- identity association;
- review/export;
- protected storage/retention where applicable;
- security alarms/events if claimed.

INPSan implementation targets:
- Event Store security schema;
- authentication/authorization events;
- configuration/privileged-operation audit;
- update/certificate/secret events;
- alert-control audit.

### FIA — Identification and Authentication
Candidate coverage:
- user identification;
- authentication;
- authentication failure handling;
- authenticator management;
- service/node identity where in TOE.

INPSan targets:
- named administrators;
- local authentication;
- optional directory-backed identities;
- MFA for privileged profiles;
- service identities.

### FMT — Security Management
Candidate coverage:
- management of security functions/data;
- role management;
- restricted security-function invocation;
- secure defaults.

INPSan targets:
- capability-based RBAC;
- user/role/security policy;
- certificate/secret/update permissions;
- storage security policy.

### FTA — TOE Access
Candidate coverage:
- session establishment;
- termination;
- inactivity;
- access history where selected.

INPSan targets:
- idle/absolute timeout;
- logout/revocation;
- reauthentication for protected actions.

### FTP — Trusted Path / Trusted Channels
Candidate coverage:
- administrator trusted path;
- protected external service channels where claimed.

INPSan targets:
- HTTPS management;
- protected directory/PKI channels;
- future mTLS Central Manager channel if in TOE.

### FCS — Cryptographic Support
Candidate coverage depends on exact cryptographic claim and module boundary.

INPSan targets may include:
- TLS mechanisms;
- password hashing;
- signature/update verification;
- certificate/key handling;
- encryption/key management where directly claimed.

Cryptographic requirements must be aligned with laboratory/scheme policy before final selection.

### FPT — Protection of the TSF
Candidate coverage:
- trusted data/configuration integrity;
- reliable timestamps;
- self-protection/failure behavior;
- update integrity where applicable.

INPSan targets:
- configuration integrity;
- signed/verified updates;
- controlled failure;
- time-health/evidence protection.

### FDP — User Data Protection
Applicability is limited and must be justified.

Possible use where the TOE directly enforces:
- storage-object access/presentation policy;
- initiator/LUN authorization;
- export/share policy;
- protected security metadata.

Do not treat all customer stored data as TOE-managed application data without an explicit boundary decision.

### Resource/availability requirements
Select only if a formal TOE security claim is made for management-plane resource controls or availability behavior.

## 7.2 Security Assurance Requirements
TBD with laboratory.

Evidence planning already required:
- configuration management/version control;
- secure lifecycle/build;
- delivery/update integrity;
- functional specification;
- architecture/design;
- administrator guidance;
- test plan/results;
- vulnerability analysis;
- reproducible evidence package.

## 8. TOE Summary Specification

This section will map each final SFR to concrete INPSan mechanisms.

Initial mechanism candidates:

### TSS-01 Identity Service
Named identities, password/authenticator verification, directory integration, MFA and service principals.

### TSS-02 Authorization Engine
Capability-based permissions, deny-by-default, object/scope enforcement and protected actions.

### TSS-03 Session Security
Server-side sessions/tokens, rotation, timeout, revocation, CSRF/origin controls.

### TSS-04 Security Audit Plane
Security event schema, actor/action/target/outcome/correlation, retention/integrity/export.

### TSS-05 Secure Management Transport
TLS/certificate trust and lifecycle for Web/API.

### TSS-06 Secure Command/Storage Adapter
Strict schemas, allow-listed parameters, no unsafe shell concatenation, controlled privilege boundary and operation audit.

### TSS-07 Storage Security Policy
FC/STMF/iSCSI/NFS/SMB policy enforcement and secure-profile validation where included.

### TSS-08 Secrets and Certificates
Protected storage/permissions, no log leakage, rotation/revocation and server-side hardware-management credentials.

### TSS-09 Secure Update
Signed artifact/manifest verification, authorization, version controls, rollback/recovery and audit.

### TSS-10 Security Configuration / Recovery
Secure defaults, configuration backup/restore, protected snapshot/recovery policy and integrity checks.

## 9. Evaluation Evidence Map

Each final SFR must link to:
- requirement/control ID;
- architecture/ADR;
- source module/commit;
- configuration;
- deterministic test ID;
- negative test ID where applicable;
- evidence artifact/hash;
- release/build;
- status PASS/PARTIAL/GAP/N/A;
- exception/risk decision.

PASS requires implementation + test + retained evidence.

## 10. Security Testing Scope

At minimum:
- authentication bypass and brute-force resistance;
- RBAC/BOLA/BFLA;
- session fixation/replay/logout;
- CSRF/XSS/SSRF/path traversal/file handling;
- OS command injection;
- TLS/certificate configuration;
- secret/log leakage;
- storage authorization/isolation;
- secure update tamper/downgrade tests;
- privilege escalation;
- audit tamper and coverage;
- resource-abuse tests;
- independent penetration test and remediation retest before evaluation candidate.

## 11. Guidance Deliverables

Required:
- Secure Installation Guide;
- Secure Administration Guide;
- Network/Management Isolation Guide;
- FC/iSCSI Secure Deployment Guide;
- NFS/SMB Secure Profile Guide if enabled;
- Certificate/Key/Secret Management Guide;
- Update/Rollback Guide;
- Audit/Incident Response Guide;
- Backup/Recovery Guide;
- Evaluated Configuration Guide.

## 12. Open Evaluation Decisions

1. Final TOE inclusion/exclusion of OmniOS/OpenZFS/COMSTAR.
2. Mandatory AFTA PP or ST-only route.
3. Assurance package/EAL/equivalent.
4. Exact cryptographic requirements.
5. Storage-protocol evaluation scope.
6. Required vulnerability-analysis depth.
7. Required source review/penetration methodology.
8. Allowed external dependencies.
9. Evaluated hardware matrix.
10. Permitted disabled/non-evaluated features.

## 13. Freeze rule

The ST cannot become an evaluation baseline until the exact build, TOE interfaces, enabled features, security configuration and laboratory requirements are version-frozen.
