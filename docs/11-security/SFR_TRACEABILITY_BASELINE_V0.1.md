# INPSan SFR Traceability Baseline v0.1

Status: **DRAFT — CANDIDATE SFR SET / NO FINAL CONFORMANCE CLAIM**  
Date: 2026-09-28  
Parent: `WP-3.3-003` / `CP-SEC-001`

## Purpose

Bridge the Security Target to engineering implementation by mapping candidate Common Criteria security functional components to INPSan mechanisms, implementation status, verification and evidence.

Source baseline: CC:2022 Part 2 Release 1. Exact SFR selection, assignments, selections and dependencies remain subject to final TOE scope and assigned-laboratory review.

## Candidate SFR mapping

| SFR | Purpose in INPSan | Candidate INPSan mechanism | Current status | Initial test/evidence target |
|---|---|---|---|---|
| `FAU_GEN.1` Audit data generation | Generate security-relevant audit records | Security Audit Plane / Event Store schema | PARTIAL | SEC-AUD-001 event coverage; version-bound audit samples |
| `FAU_GEN.2` User identity association | Bind auditable events to user identity | Named principal + session/correlation identity | GAP | SEC-AUD-002 actor attribution |
| `FIA_UID.2` User identification before any action | Require identity before protected management actions | Independent Control Plane identity layer | GAP | SEC-AUTH-001 anonymous/protected-endpoint negative test |
| `FIA_UAU.2` User authentication before any action | Authenticate before protected actions | Local/directory authentication service | GAP | SEC-AUTH-002 auth bypass negative test |
| `FIA_AFL.1` Authentication failure handling | Detect/respond to repeated failed authentication | Rate limit/failure policy + audit/alert | GAP | SEC-AUTH-003 brute-force/failure handling |
| `FMT_SMR.1` Security roles | Maintain and associate users with authorized roles | Capability-based RBAC role mapping | GAP | SEC-RBAC-001 role assignment and negative authorization |
| `FMT_SMF.1` Specification of Management Functions | Define security management functions provided by TSF | Control Plane management API and protected operation catalog | PARTIAL | SEC-MGMT-001 management-function inventory against routes |
| `FMT_MTD.1` Management of TSF data | Restrict management of security-relevant state | RBAC for users/roles/policy/certificates/secrets/audit config | GAP | SEC-RBAC-002 TSF-data modification authorization |
| `FTA_SSL.3` TSF-initiated termination | Terminate inactive interactive sessions | Idle timeout | GAP | SEC-SES-001 inactivity timeout |
| `FTA_SSL.4` User-initiated termination | Allow secure user logout | Server-side logout/session revocation | GAP | SEC-SES-002 logout/replay test |
| `FTP_TRP.1` Trusted path | Protected path between remote administrator and TOE | HTTPS/TLS Web UI/API | GAP | SEC-TLS-001 TLS-only admin path / downgrade rejection |
| `FTP_ITC.1` Inter-TSF trusted channel | Protected channels to trusted IT products | LDAPS/PKI/SIEM integrations; future mTLS Central Manager | GAP | SEC-CHAN-001 peer/channel validation |
| `FPT_STM.1` Reliable time stamps | Provide reliable timestamps for TSF functions/audit | System time + trusted NTP + time-health monitoring | GAP | SEC-TIME-001 time source/drift/change audit |
| `FPT_TST.1` TSF self-testing | Self-test selected TSF/integrity functions | Startup readiness + package/config integrity checks | PARTIAL | SEC-INT-001 startup/integrity self-test |
| `FDP_ACC.1` Subset access control | Define access-control policy over selected objects/operations | Object-level RBAC for pools/datasets/LUNs/shares/security objects | GAP / APPLICABILITY OPEN | SEC-OBJ-001 object cross-access tests |
| `FDP_ACF.1` Security attribute-based access control | Enforce access based on identity/role/scope/object attributes | Authorization engine | GAP / APPLICABILITY OPEN | SEC-OBJ-002 role/scope/object rule tests |
| `FCS_COP.1` Cryptographic operation | Define cryptographic operations used by TOE | TLS, password hashing/signature verification subject to crypto boundary | GAP / LAB DECISION | SEC-CRYPTO-001 algorithm/configuration evidence |

## Notes on current applicability

### Audit
`FAU_GEN.1` and `FAU_GEN.2` are strong candidates because INPSan already has Event Store/Alert infrastructure but lacks complete security-audit coverage and identity association.

### Identity/authentication
`FIA_UID.2`, `FIA_UAU.2` and `FIA_AFL.1` directly match the planned production management model. The current loopback/read-only development prototype does not satisfy these requirements.

### Security management/RBAC
`FMT_SMR.1`, `FMT_SMF.1` and `FMT_MTD.1` are direct candidates for the capability-based role model and protected security configuration.

### Session security
`FTA_SSL.3` and `FTA_SSL.4` map to idle termination and explicit logout. Additional session requirements may be selected after full CC dependency/coverage analysis.

### Trusted communications
`FTP_TRP.1` is a direct candidate for the administrator Web/API path. `FTP_ITC.1` is a candidate for protected channels to trusted external IT systems.

### Reliable time
`FPT_STM.1` is especially important because `FAU_GEN.1` depends on reliable timestamps in CC:2022 Part 2.

### Self-test/integrity
`FPT_TST.1` may map to startup readiness and integrity checks only if the final implementation genuinely performs the selected TSF self-tests/integrity verification. Existing readiness telemetry alone is not sufficient to claim PASS.

### FDP access-control components
`FDP_ACC.1` / `FDP_ACF.1` are useful candidates for object-level authorization, but final use depends on whether the evaluated policy is framed as user-data/object access control or purely TSF security management. Laboratory review is required before final selection.

### Cryptographic SFRs
`FCS_COP.1` and related key-management components cannot be finalized until:
- cryptographic boundary is defined;
- algorithms/key sizes/standards are fixed;
- implementation/provider is known;
- AFTA/laboratory cryptographic evidence expectations are confirmed.

## Immediate implementation backlog derived from SFRs

### SEC-IMP-01 — Identity foundation
Implement named user identity and protected authentication before production management actions.

### SEC-IMP-02 — Authorization engine
Implement capability-based roles plus object/scope checks; UI visibility must not be the security boundary.

### SEC-IMP-03 — Security audit schema
Required minimum:
`event_id, timestamp, actor_id, actor_type, source, session_or_correlation_id, action, target_type, target_id, permission, outcome, reason, client_context, product_version`.

### SEC-IMP-04 — Session security
Implement:
- high-entropy server-issued session/token;
- rotation after auth/privilege change;
- idle timeout;
- absolute lifetime policy;
- explicit logout/revocation;
- CSRF/origin protection for browser state changes.

### SEC-IMP-05 — Trusted management path
Implement TLS-only production Web/API access with version-bound certificate/cipher policy and no insecure fallback.

### SEC-IMP-06 — Secure operation broker
State-changing storage/system actions must pass through:
1. authenticated principal;
2. permission check;
3. object/scope check;
4. strict parameter schema/allow-list;
5. safe process execution with no unsafe shell interpolation;
6. audit before/after outcome;
7. deterministic error mapping.

### SEC-IMP-07 — Time/evidence integrity
Resolve trustworthy time source, monitor time health and bind audit evidence to reliable timestamps.

## Acceptance rule

A mapped SFR remains `GAP` or `PARTIAL` until:
- the exact SFR assignment/selection is defined;
- implementation exists in the evaluated build;
- dependencies are satisfied;
- positive and negative tests pass;
- evidence is retained and version-bound.

This file is an engineering traceability baseline, not a final Security Target requirement statement.
