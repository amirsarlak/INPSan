# INPSan Control Plane Security Contract v1.0

Status: **IMPLEMENTATION GATE**  
Date: 2026-09-28  
Parent: CP-KB-001 / WP-3.3-001 / Issue #7

## 1. Scope

This contract defines minimum security requirements for the INPSan 3.3 Control Plane. Read-only prototype endpoints may be developed before full authentication only when bound to loopback/test interfaces and clearly marked development-only. No production state-changing endpoint is permitted before this contract is implemented and tested.

## 2. Identity model

Principal classes:
- local named administrator;
- directory-backed named user (future integration);
- service principal;
- Central Manager node/fleet principal (future);
- emergency break-glass administrator.

Anonymous access is prohibited for production management endpoints.

## 3. Authentication requirements

- credentials never embedded in URLs;
- password verification uses a modern salted password hashing scheme when local passwords are introduced;
- login failure is audited;
- rate limiting / anti-brute-force control is required;
- break-glass use is separately audited;
- service/Central Manager identities use certificates or equivalent non-human credentials;
- plaintext authentication transport is prohibited.

## 4. Session requirements

- high-entropy server-issued session identifier;
- inactivity timeout;
- absolute lifetime;
- explicit logout/revocation;
- session rotation after authentication/privilege change;
- CSRF protection for browser state-changing actions;
- secure cookie attributes where cookie sessions are used.

## 5. RBAC roles

Initial product roles:

| Role | Purpose |
|---|---|
| `viewer` | Read health/performance/topology allowed by scope |
| `operator` | Viewer + incident acknowledgement and approved operational actions |
| `storage-admin` | Storage configuration/maintenance actions within policy |
| `security-admin` | Identity, RBAC, certificates, audit/security policy |
| `auditor` | Read audit/compliance/evidence; no configuration changes |
| `platform-admin` | Full product administration, still subject to audit and protected-action rules |

Permissions are capability-based; role names are mappings, not hard-coded authorization checks.

## 6. Permission namespace

Initial permission families:
- `system.read`;
- `health.read`;
- `storage.read` / future `storage.manage`;
- `topology.read`;
- `performance.read`;
- `alerts.read` / future `alerts.ack` / `alerts.silence`;
- `events.read`;
- `reports.read` / future `reports.manage`;
- `audit.read`;
- `security.read` / future `security.manage`;
- `users.manage`;
- `roles.manage`;
- `updates.manage`;
- `fleet.read` / future `fleet.manage`.

## 7. Authorization rules

- deny by default;
- every endpoint declares required permission;
- authorization is enforced server-side;
- object/site/node scope is evaluated separately from role;
- UI visibility is not a security boundary;
- protected/destructive actions may require step-up confirmation/approval in future versions.

## 8. Audit schema

Security/management audit records contain at minimum:

`event_id, timestamp, actor_id, actor_type, source, session_id/correlation_id, action, target_type, target_id, permission, outcome, reason, client_context, product_version`

Secrets and credential material are prohibited in audit records.

Required audited events include:
- authentication success/failure/logout;
- authorization denial;
- role/user/security-policy changes;
- configuration changes;
- update/rollback;
- alert acknowledge/silence;
- node enrollment/removal;
- certificate/secret lifecycle changes;
- break-glass use.

## 9. API transport

- production API requires TLS;
- Central Manager enrollment requires mutually authenticated node identity;
- no silent insecure fallback;
- supported TLS/cipher profile is version-bound to the security baseline;
- certificate trust and renewal failures generate security alerts.

## 10. Input/output security

- strict schema validation;
- bounded input sizes;
- canonical entity identifiers;
- explicit error codes without stack/secret leakage;
- output filtering by permission and scope;
- support bundles/reports must support sensitive-data filtering.

## 11. Secrets

- secrets are not stored in source control;
- filesystem permissions and process boundaries protect service secrets;
- BMC/Redfish secrets stay server-side;
- rotation and revocation are supported;
- secrets are omitted from normal logs, dumps and exports.

## 12. Development-only read-only prototype exception

A pre-auth read-only prototype is allowed only if:
- it binds to loopback by default;
- it has no state-changing endpoints;
- it exposes no credentials/secrets;
- it is explicitly versioned `dev`;
- it is not accepted as GA/security-complete;
- evidence clearly distinguishes prototype from production security baseline.

## 13. Security acceptance gate

Before any state-changing endpoint is accepted:
- AuthN implemented/tested;
- RBAC implemented/tested;
- audit implemented/tested;
- TLS configuration accepted;
- input validation tests pass;
- secrets policy implemented;
- negative authorization tests pass;
- security evidence indexed.