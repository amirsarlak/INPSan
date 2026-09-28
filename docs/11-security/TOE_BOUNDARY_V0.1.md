# INPSan TOE Boundary v0.1

Status: **DRAFT — EVALUATION FOUNDATION**  
Date: 2026-09-28  
Parent: `WP-3.3-003`

## 1. TOE working name

**INPSan Secure Storage Management Appliance — Single-Node 3.3 Evaluation Candidate**

The working name is intentionally narrower than the whole appliance stack. Final naming and boundary are subject to evaluation-laboratory confirmation.

## 2. Evaluation principle

The TOE is the INPSan-developed management/security/productization layer that governs and observes storage services on the supported OmniOS/OpenZFS/COMSTAR platform.

INPSan is not a new operating system and is not an OmniOS fork.

## 3. Proposed TOE components

### 3.1 Management and Control Plane
- INPSan Control Plane service;
- versioned management REST API;
- privileged operation broker / command-execution wrapper;
- configuration service;
- asynchronous job and scheduler security boundary where present.

### 3.2 Identity and access control
- local named identities;
- directory-backed identity integration where enabled;
- authentication/session management;
- RBAC and permission evaluation;
- scoped/object-level authorization;
- emergency/break-glass control and audit.

### 3.3 Security audit and event functions
- management/security audit generation;
- security-relevant Event Store functions;
- privileged-operation traceability;
- audit retention/export/integrity functions included in the evaluated release.

### 3.4 Secure management interface
- INPSan Web UI;
- management REST API;
- TLS/certificate handling used by those interfaces;
- security-relevant headers/session controls;
- server-side request validation and authorization.

### 3.5 Storage-control security functions
Where implemented by INPSan and included in the evaluated build:
- FC initiator/target inventory and policy;
- STMF host/target/LU presentation policy;
- iSCSI authorization/authentication policy;
- NFS/SMB secure-profile configuration controls;
- protected handling of destructive storage operations;
- snapshot/replication protection policy.

Underlying OpenZFS/COMSTAR execution mechanisms remain platform dependencies unless the laboratory explicitly requires them inside the TOE.

### 3.6 Update, integrity and secrets functions
- INPSan package/update authenticity verification;
- release manifest verification;
- security configuration integrity checks;
- secret/certificate lifecycle functions included in the evaluated release;
- rollback security controls.

## 4. Proposed TOE interfaces

External logical interfaces:
1. Administrator browser -> INPSan Web UI over HTTPS.
2. Administrative/API client -> INPSan REST API over HTTPS.
3. Optional directory service -> INPSan identity integration over protected channel.
4. Optional SIEM/syslog/notification integration -> evaluated outbound interface only when enabled in the evaluated configuration.
5. Hardware-management integration -> iLO/Redfish server-side interface.
6. Storage administration adapter -> controlled interface from INPSan to OpenZFS/COMSTAR/STMF/SMF commands and APIs.
7. Package/update source -> signed update/import interface.
8. Future Central Manager -> mutually authenticated management interface; excluded from Single-Node 3.3 unless explicitly included.

## 5. TOE boundary exclusions / operational environment

Default exclusions for v0.1:
- HPE server hardware, disks, power supplies and physical enclosure;
- FC switches/fabric;
- host HBAs and hypervisors;
- customer LAN/SAN infrastructure;
- external AD/LDAP, DNS, NTP, PKI/CA and SIEM systems;
- OmniOS/illumos kernel and standard drivers;
- OpenZFS implementation;
- COMSTAR/STMF implementation;
- third-party SMB/NFS service implementation;
- iLO firmware;
- customer data payload/content;
- backup products external to INPSan;
- Central Manager / multi-node fleet plane for the Single-Node evaluation candidate.

These components may remain security-relevant environmental dependencies and must receive explicit assumptions/configuration guidance.

## 6. Security dependency boundary

The TOE may invoke upstream platform functions but must not treat their existence as proof of an INPSan security claim.

Example:
- COMSTAR can implement LUN presentation;
- the INPSan security claim is the authenticated/authorized/audited policy path that permits, validates and records that presentation.

Likewise:
- OpenZFS can provide encryption/snapshots;
- INPSan may claim only the management/key/policy/security controls it actually implements, verifies and documents.

## 7. Data classes crossing the TOE

Security-relevant:
- credentials/authenticators;
- session identifiers/tokens;
- RBAC policy;
- storage configuration metadata;
- host/initiator identifiers;
- certificates/keys/secrets;
- audit events;
- system/storage health metadata;
- update manifests/signatures;
- operational telemetry used for security decisions.

Not intended for application processing:
- customer file/block payload content.

## 8. Privileged operation boundary

High-impact operations require explicit server-side authorization and audit, including at minimum:
- pool/dataset/zvol destructive operations;
- LUN/target/view creation/change/removal;
- NFS/SMB export/share security changes;
- snapshot/replication protection deletion;
- account/role/policy changes;
- certificate/key/secret lifecycle actions;
- update/rollback;
- audit-policy changes;
- break-glass activation.

## 9. Availability independence rule

The INPSan management/security plane must not become a single failure point for existing storage I/O.

Failure or restart of the Control Plane must not intentionally terminate already-established storage data service unless the underlying platform itself requires it for a separately approved safety reason.

## 10. Evaluation configurations to define later

The ST must freeze:
- exact INPSan build;
- OmniOS supported build;
- enabled management interfaces;
- enabled storage protocols;
- authentication mode;
- external dependencies;
- TLS/certificate profile;
- update method;
- audit export configuration;
- hardware compatibility subset.

## 11. Open decisions requiring laboratory confirmation

- whether upstream OmniOS/OpenZFS/COMSTAR components must be included inside the formal TOE boundary;
- whether the product category is evaluated ST-only or against a mandated national/CC PP;
- assurance package/EAL or equivalent program profile;
- permitted external identity/PKI/SIEM dependencies;
- whether FC/iSCSI/NAS protocol functions must be directly evaluated or treated as operational-environment services controlled by the TOE;
- cryptographic-module evidence requirements.

## 12. Boundary acceptance gate

This v0.1 is a design baseline only. It becomes evaluation-bound only after:
- laboratory category/PP decision;
- exact evaluated release freeze;
- interface inventory verified against the build;
- SFR-to-component mapping completed;
- unsupported/excluded features documented in administrator guidance.
