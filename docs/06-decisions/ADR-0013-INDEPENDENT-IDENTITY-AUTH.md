# ADR-0013 — Independent INPSan Identity and Authentication

Status: **ACCEPTED FOR 3.3 IMPLEMENTATION**  
Date: 2026-09-28  
Parent: CP-SEC-001 / WP-3.3-003

## Context

INPSan 3.3 requires a certifiable management-plane identity boundary that is owned, testable and auditable by INPSan rather than implicitly inheriting authentication behavior from napp-it or another UI layer.

The security/evaluation baseline requires named identities, authentication before protected management actions, session control, auditable authentication outcomes and future RBAC/MFA integration.

## Decision

INPSan shall implement an independent identity/authentication layer for the Control Plane.

Initial 0.2-dev design:
- named local users;
- dedicated local user store;
- salted password verifier;
- secure random session tokens;
- only token hashes retained in server memory;
- loopback-only HTTP development build until TLS milestone SEC-IMP-05;
- existing read-only management endpoints require authentication;
- no storage state-changing endpoint is introduced by SEC-IMP-01;
- login success/failure/logout produce development security-audit events.

## Password-verifier design

The current development implementation uses PBKDF2-HMAC-SHA256 with per-user random salt and an iteration count stored with the verifier.

This is a development baseline, not a frozen cryptographic certification claim. Before evaluation freeze:
- benchmark the KDF on supported appliance hardware;
- confirm current scheme/laboratory cryptographic requirements;
- approve the final parameter set;
- define migration/versioning for password verifiers.

Plaintext passwords must never be stored.

## Session design

- 256-bit random bearer value generated from the OS secure random source;
- server stores only SHA-256 token key in session state;
- idle timeout and absolute lifetime;
- explicit revocation/logout;
- token not accepted in URL/query string;
- bearer/session transport must remain loopback-only until TLS is implemented.

## Provisioning

Initial named-user provisioning is local/offline. Password material must not be accepted as a command-line argument.

Remote user-management endpoints are deferred until RBAC, audit, TLS, secrets handling and negative authorization testing are available.

## Knowledge-based / R&D evidence value

This component is proprietary product logic and shall retain:
- architecture rationale;
- source ownership;
- API/module contract;
- threat/attack mapping;
- complexity and dependency data;
- unit/static/live tests;
- performance/KDF benchmarks;
- version lineage;
- security evidence.

This enables demonstrable separation between upstream storage capabilities and INPSan-developed security/productization technology.

## Passive-defense / resilience considerations

Authentication failure handling must:
- generate actionable audit evidence;
- resist brute-force abuse;
- avoid unsafe lockout that prevents legitimate emergency administration;
- preserve a separately governed break-glass design;
- not enter the storage data path or interrupt existing storage I/O.

## Consequences

Positive:
- independent product security boundary;
- clearer Common Criteria SFR mapping;
- stronger accountability and knowledge-based product ownership;
- foundation for RBAC/MFA/audit.

Costs:
- identity lifecycle and recovery become INPSan responsibilities;
- cryptographic/KDF parameters require maintenance and evidence;
- HA/persistent session design remains future work.

## Status rule

SEC-IMP-01 remains PARTIAL until live OmniOS tests demonstrate:
- user-store permissions;
- valid login;
- invalid-login rejection;
- protected endpoint rejection without token;
- protected endpoint success with token;
- logout/revocation;
- idle/absolute expiry behavior;
- rate-limit behavior;
- no password/token leakage in audit/logs;
- dependency availability on the supported OmniOS build.
