# INPSan National Security & Passive-Defense Alignment v0.1

Status: **ACTIVE CROSS-CUTTING BASELINE**  
Date: 2026-09-28  
Parent: CP-KB-001 / CP-SEC-001 / WP-3.3-003

## Purpose

Translate publicly available AFTA-oriented product-security requirements and national passive-defense principles into engineering requirements for INPSan 3.3+.

This document is not a claim of AFTA certification or full regulatory conformance. Final evaluated requirements remain subject to the assigned laboratory, official current documents, product category and frozen Security Target.

## A. AFTA-oriented network-application security baseline

Applicable Web/API/control-plane functions shall be evaluated against the following categories:

### A1. Security audit and logging
Required product capabilities:
- log security-relevant operations and authentication/session events;
- record timestamp, event type, actor identity, outcome and source context;
- protect audit records against unauthorized access/modification/deletion;
- provide authorized filtering/sorting/search;
- detect or prevent tampering where applicable;
- warn before audit-storage exhaustion;
- preserve logging behavior during capacity/failure conditions according to an approved policy;
- keep security audit understandable for authorized operators.

INPSan design targets:
- Event Store security schema;
- append-only/protected evidence path;
- actor/action/target/outcome/correlation model;
- audit-capacity/freshness health;
- audit search/filter/report views.

### A2. Identification and authentication
Required capabilities:
- configurable failed-authentication threshold/policy;
- defensive response to repeated failed authentication;
- user security attributes including identifier, auth method, auth data/status and role;
- password/authenticator lifecycle;
- no protected management action before successful authentication;
- strong/second-factor authentication for privileged remote administration where applicable;
- retain authentication history needed for security operations.

### A3. User data / access-control protection
Required capabilities:
- defined access-control policy;
- active/inactive object handling;
- authorization of operations over protected objects;
- user/role/scope enforcement;
- no UI-only authorization.

For INPSan this applies especially to:
- pools/datasets/zvols;
- LUNs/targets/views;
- initiator/host groups;
- NFS/SMB exports/shares;
- snapshots/replication policies;
- audit/security configuration.

### A4. Security management
Required capabilities:
- restrict security-management functions to authorized roles;
- define/manage/change security behavior under controlled privilege;
- protect security attributes and defaults;
- audit security-policy changes.

### A5. Protection of security functions
Required capabilities:
- reliable trusted time;
- software/update integrity;
- security-function failure handling;
- secrets/certificates protection;
- integrity/self-test where claimed.

### A6. TOE/Product access and sessions
Required capabilities:
- session establishment/termination rules;
- idle/absolute timeout;
- session revocation;
- failed/limited session handling;
- protected logout/replay behavior.

### A7. Trusted channels
Where selected:
- HTTPS/TLS;
- server/client TLS validation;
- certificate-chain validation;
- SSH restrictions where applicable;
- no silent downgrade to insecure transport.

Exact protocol/cipher choices shall be aligned to the current official evaluation requirements rather than copied mechanically from older documents.

## B. Passive-defense engineering baseline

### B1. Monitoring, detection and warning
INPSan shall support:
- continuous health and security monitoring;
- threat/vulnerability indicators;
- early warning;
- severity/context;
- correlation across storage, network, hardware and security telemetry.

### B2. Predictive operation
The product shall progressively support:
- baseline deviation detection;
- pre-failure indicators;
- capacity/saturation forecast;
- anomaly detection;
- failure-risk estimation;
- warning before service-impacting conditions where evidence supports prediction.

### B3. Continuity and resilience
Required design properties:
- management failure must not unnecessarily interrupt existing storage I/O;
- safe local operation during Central Manager outage;
- backup/restore verification;
- rollback/recovery paths;
- redundancy/dependency visibility;
- degraded-state awareness;
- recovery readiness reporting.

### B4. Insider and privileged-operation visibility
Required:
- named accountable administrators;
- privileged-operation audit;
- destructive-action traceability;
- role/permission change audit;
- unusual destructive behavior detection roadmap;
- break-glass use visibility.

### B5. Self-protection and attack-surface reduction
Required:
- minimal exposed services;
- management-plane isolation;
- secure defaults;
- strong identity/RBAC/MFA;
- TLS;
- signed updates;
- dependency/vulnerability management;
- penetration testing;
- storage-protocol hardening;
- secret management.

### B6. Readiness and exercise evidence
Roadmap target:
- operational readiness report;
- recovery drill evidence;
- incident-response runbooks;
- security-event simulation;
- storage failure/degraded-state drills in approved test environments;
- measurable RTO/RPO/recovery evidence where applicable.

## C. Product reporting requirements derived from national-security use cases

The following report/dashboard families become roadmap targets:

1. Security Posture Summary
2. Privileged Operations Report
3. Authentication & Access Anomaly Report
4. Storage Availability & Resilience Report
5. Backup/Snapshot/Recovery Readiness Report
6. Dependency & Single-Point-of-Failure Report
7. Capacity and Saturation Forecast
8. Storage I/O Anomaly Report
9. FC/iSCSI/NFS/SMB Security Posture
10. Hardware/Firmware Health & Vulnerability Exposure
11. Time/Audit Integrity Health
12. Update/SBOM/Vulnerability Status
13. Incident Timeline / Root-Cause Evidence
14. Readiness / Cyber-Resilience Executive Report

Each report must state:
- intended persona;
- decision/use case;
- input sources;
- freshness;
- limitations;
- confidence/quality where predictive;
- auditability of configuration.

## D. Traceability rule

Every national-security/passive-defense requirement must map to:
- requirement ID;
- source/reference;
- applicability;
- architecture/ADR;
- implementation module;
- test;
- evidence;
- status;
- exception/risk owner.

No requirement is PASS without retained evidence.
