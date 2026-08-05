# INPSan Security Hardening Baseline

Document status: `APPROVED AS CROSS-CUTTING WORKSTREAM`  
Version: `1.0`  
Date: `2026-08-06`

## Policy decision

Hardening is mandatory throughout both strategic stages. It is not postponed until product completion.

The hardening program uses:

- OmniOS vendor guidance and supported package/update mechanisms as the platform authority;
- CIS Oracle Solaris guidance only as a **tailoring reference**, never as a drop-in OmniOS benchmark;
- NIST SP 800-53 control families for system/security coverage;
- the latest final NIST SSDF release as the secure-development baseline, while monitoring later drafts separately;
- OWASP ASVS 5.0 Level 2 as the default Web/API application-security target, with selected Level 3 controls for high-impact administrative operations.

## Operating-system support baseline

- Production remains on the validated OmniOS `r151054` LTS baseline until a controlled compatibility branch validates a later release.
- A later stable release must not replace the LTS production baseline based only on availability.
- Upgrade acceptance requires driver, HBA, COMSTAR/STMF, ZFS, SMF, telemetry, UI, alert and rollback regression testing.
- Signed package verification must remain enabled for trusted publishers.

## H0 — Asset, threat and trust-boundary definition

Required outputs:

- asset inventory;
- management-plane/data-plane diagram;
- trust-boundary diagram;
- privileged-operation inventory;
- attack-surface register;
- threat model for Web UI, API, SMF services, update channel, license system and storage protocols.

## H1 — Host and SMF hardening

Minimum controls:

- remove/disable unnecessary services and packages;
- explicit SMF service dependencies and restart policy;
- least-privilege service identities where technically feasible;
- restrictive file ownership and permissions;
- no world-writable executable/configuration locations;
- secure temporary-file handling;
- SSH key-based administrative access;
- prohibit direct remote root login;
- management access restricted by network policy;
- time synchronization and trusted time source;
- centralized/safe log retention;
- controlled core-dump and diagnostic-data handling;
- periodic integrity and configuration-drift checks.

## H2 — Identity, authentication and authorization

- unique named administrative accounts;
- RBAC with scoped roles and least privilege;
- no shared default administrator credential;
- MFA-ready architecture for future enterprise identity integration;
- session timeout and secure re-authentication for destructive actions;
- account lockout/rate limiting designed to avoid denial-of-service abuse;
- auditable privilege changes;
- break-glass access with explicit logging and review.

## H3 — Web UI and REST API security

Default target: OWASP ASVS 5.0 Level 2.

Selected Level 3 controls apply to:

- pool destruction;
- disk replacement;
- snapshot/replication policy deletion;
- LUN/target changes;
- credential, certificate and license management;
- security-policy modification.

Required control groups:

- TLS-only management access;
- secure certificate lifecycle;
- CSRF protection;
- XSS and output-encoding controls;
- command-injection prevention;
- strict server-side authorization;
- request validation and safe error handling;
- secure session cookies and session invalidation;
- API versioning and rate controls;
- no secrets in URLs, logs or browser storage;
- content-security and browser-hardening headers;
- audit linkage between user, request, job and storage action.

## H4 — Storage and data-plane security

- separate management and storage/data networks where possible;
- FC zoning and STMF host/LUN groups;
- explicit LUN masking and deny-by-default presentation;
- iSCSI CHAP policy, mutual CHAP where justified, and network segmentation;
- SMB/NFS service hardening based on actual deployment scope;
- encryption-at-rest capability and key-management design where enabled;
- snapshot/hold/replication policy protection against unauthorized deletion;
- destructive-operation confirmation and delayed/background job controls;
- no license state may interrupt existing storage I/O.

## H5 — Secrets, certificates and licensing keys

- private signing keys remain outside source repositories and build artifacts;
- production secrets stored encrypted with restricted access;
- no hard-coded credentials or reusable default secrets;
- certificate rotation and expiry monitoring;
- license verification uses an embedded public key only;
- rehost/recovery workflow for hardware replacement;
- audit all entitlement changes without exposing license secrets.

## H6 — Software supply chain and release security

- dependency inventory and SBOM for every release;
- third-party license inventory;
- source review and secret scanning;
- SAST, dependency/SCA and package-malware checks;
- signed release manifest and SHA256 hashes;
- reproducible or at least traceable builds;
- separation of build, signing and release authority;
- vulnerability intake and security-update policy;
- retained source commit, package, test report and release-evidence linkage.

## H7 — Logging, alerting and incident response

- security events stored separately from transient UI state;
- authentication, authorization and destructive operations audited;
- log tampering/retention controls;
- clock-health monitoring;
- alert deduplication and suppression;
- notification channels remain disabled until delivery/security acceptance;
- incident-response runbooks for compromise, credential loss, malicious admin action and update failure.

## H8 — Backup, recovery and resilience

- configuration backup distinct from user data backup;
- encrypted export of secrets where applicable;
- tested restore to replacement hardware/VM;
- recovery of RBAC, certificates, license state and alert configuration;
- rollback package retained for every production update;
- periodic restore drill with evidence.

## Security acceptance gate for Stage 1 GA

Stage 1 cannot become GA until:

- all critical and high-risk findings are closed or formally risk-accepted;
- authentication/RBAC/audit/TLS are operational;
- management-plane exposure is restricted;
- upgrade, rollback and restore tests pass;
- SBOM and third-party license report exist;
- security test evidence is linked to the release;
- no hidden or unapproved outbound notification channel is active.

## Reference sources

- OmniOS: https://omnios.org/
- OmniOS downloads/support tracks: https://omnios.org/download
- OmniOS signed packages: https://omnios.org/info/signed_packages
- CIS Oracle Solaris benchmark reference: https://www.cisecurity.org/benchmark/oracle_solaris
- NIST SSDF: https://csrc.nist.gov/Projects/ssdf
- NIST SP 800-53: https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/
