# INPSan Security Architecture v1.0

Status: **3.3 DESIGN BASELINE — implementation gates defined**  
Date: 2026-09-28

## 1. Security objective

Protect the management and productization layers of INPSan without introducing a dependency that can interrupt the underlying storage data path.

## 2. Trust zones

1. **Storage Data Plane** — OpenZFS/COMSTAR/STMF and storage protocol service.
2. **Local Management Plane** — INPSan Control Plane, administration UI/API and privileged operations.
3. **Telemetry & Analytics Plane** — collectors, history, alert/event processing and predictive analytics.
4. **Hardware Management Plane** — BMC/iLO/Redfish and hardware-management interfaces.
5. **Central Management Plane** — future Central Manager and fleet operations.
6. **External Integration Plane** — directory, SIEM/syslog, ticketing, notification and approved integrations.

## 3. Mandatory controls for 3.3

### Identity and authentication
- named administrator identities;
- no shared default administrative account for routine operation;
- local emergency/break-glass path with auditable use;
- directory integration as an optional enterprise capability;
- protection against brute-force/session abuse.

### Authorization
- RBAC with explicit permissions;
- least privilege;
- storage, monitoring, security, audit and system-administration scopes;
- policy-enforced actions for destructive or high-risk operations.

### Session security
- secure session identifiers;
- inactivity/absolute timeout policy;
- explicit logout/revocation;
- CSRF protection for browser state-changing actions;
- no credentials or secrets in URLs/logs.

### Transport and certificates
- TLS for management traffic;
- mTLS or equivalent authenticated node identity for Central Manager enrollment;
- certificate lifecycle and trust-anchor management;
- no silent downgrade to insecure transport.

### Audit
- authentication success/failure;
- authorization failure;
- configuration change;
- privileged operation;
- policy change;
- update/rollback;
- node enrollment/removal;
- alert acknowledgement/silence/control actions;
- security-relevant certificate/secret events.

Audit records require reliable time, actor, action, target, outcome and correlation context.

### Secrets
- dedicated secret storage/permissions;
- rotation capability;
- secrets excluded from source control, support bundles and ordinary logs;
- BMC/Redfish credentials isolated from dashboard clients.

### Software integrity and supply chain
- signed release artifacts;
- SHA-256 checksums;
- SBOM;
- third-party license/dependency inventory;
- vulnerability/dependency scanning;
- controlled update/rollback.

## 4. Certification-readiness artifacts

Maintain a version-bound draft package for:
- Target of Evaluation (TOE) boundary;
- Security Target / security-function description;
- assumptions, threats and security objectives;
- interfaces/protocols/trust zones;
- functional test evidence;
- vulnerability analysis;
- penetration-test scope/results;
- configuration/hardening guide;
- lifecycle/build/update evidence.

Final AFTA laboratory profile/evaluation requirements must be confirmed against the assigned laboratory and current program instructions before certification freeze.

## 5. Control Plane gate

No state-changing Control Plane endpoint may be accepted until authentication, authorization, audit, input validation, error handling and transport requirements are defined and tested.

## 6. Central Manager gate

Central Manager must remain outside the storage data path. Loss of Central Manager connectivity must not stop local storage service. Remote configuration requires node identity, authorization, audit, version compatibility and rollback/failure containment.

## 7. Predictive Intelligence security/privacy

Predictive processing is local-first and uses operational telemetry/metadata by default. Customer payload content is out of scope. Model artifacts, feature schemas and inference outputs are versioned and auditable.