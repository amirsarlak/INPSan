# INPSan Security Problem Definition v0.1

Status: **DRAFT — TRACEABILITY BASELINE**  
Date: 2026-09-28  
Parent: `WP-3.3-003`

## 1. Protected assets

A1. Administrative identities and authenticators.  
A2. RBAC policy and authorization state.  
A3. Management sessions and API tokens.  
A4. Storage configuration metadata: pools, datasets, zvols, LUNs, targets, host/initiator mappings, shares/exports and protection policies.  
A5. Cryptographic keys, certificates, trust anchors and service secrets.  
A6. Security audit records and event correlation data.  
A7. INPSan software/update artifacts and trusted release metadata.  
A8. Security configuration and product configuration backups.  
A9. Availability and integrity of the management/control plane.  
A10. Security-relevant hardware/storage telemetry and identity mappings.  
A11. Existing storage service continuity: management-plane failure must not unnecessarily disrupt established data service.

Customer payload content is not intended to be processed by the management application, but storage-control actions can affect its confidentiality, integrity or availability and therefore require protection.

## 2. Threats

### T.AUTH_BYPASS
An attacker gains management access without valid authentication or bypasses identity verification.

### T.CREDENTIAL_ATTACK
An attacker guesses, reuses, steals or extracts passwords, tokens, CHAP secrets, certificates or private credentials.

### T.PRIV_ESC
An authenticated principal performs an operation outside assigned role, scope or object authorization.

### T.WEB_API_ATTACK
An attacker exploits Web/API weaknesses such as injection, OS command injection, XSS, CSRF, SSRF, path traversal, insecure file handling, unsafe deserialization, BOLA/BFLA or resource exhaustion.

### T.MGMT_CHANNEL
An attacker reads, modifies, redirects or downgrades management traffic.

### T.CONFIG_TAMPER
An attacker or unauthorized administrator changes security/storage configuration outside approved policy.

### T.AUDIT_TAMPER
An attacker modifies, deletes, suppresses or makes security audit evidence ambiguous.

### T.UPDATE_COMPROMISE
A malicious, altered, vulnerable or unauthorized package/update is installed.

### T.SUPPLY_CHAIN
A compromised dependency, embedded secret or unknown vulnerable component enters the release.

### T.STORAGE_UNAUTH
An unauthorized host/initiator/client gains access to a LUN, target, export or share.

### T.STORAGE_ADMIN_ABUSE
A privileged or compromised administrator performs destructive operations such as pool/data deletion, LUN remapping, security-policy deletion or snapshot/recovery destruction.

### T.SNAPSHOT_RECOVERY_ATTACK
An attacker deletes or compromises snapshots, backups, replication state or recovery configuration to prevent restoration.

### T.SECRET_DISCLOSURE
Secrets are exposed through logs, browser state, source code, support bundles, error messages or weak filesystem permissions.

### T.TIME_EVIDENCE
Incorrect or manipulated time undermines audit/event ordering and investigation.

### T.PLATFORM_EXPOSURE
Unnecessary services, weak host configuration or excessive privileges expose the appliance.

### T.HARDWARE_MGMT
Compromise or misuse of BMC/iLO/Redfish credentials/interfaces undermines hardware or product management.

### T.DOS_MGMT
An attacker exhausts management-plane resources or abuses expensive API operations.

### T.MISCONFIGURATION
An authorized administrator unintentionally deploys insecure FC/iSCSI/NFS/SMB or management configuration.

### T.DEPENDENCY_FAILURE
Failure of external directory, NTP, PKI, SIEM or future Central Manager causes unsafe behavior or loss of local storage service.

## 3. Organizational Security Policies

### OSP.NAMED_ADMIN
Routine administration uses accountable named identities; shared generic credentials are not accepted for normal operation.

### OSP.LEAST_PRIVILEGE
Privileges are denied by default and granted only to required roles/scopes.

### OSP.SECURE_MANAGEMENT
Production management access uses protected channels and approved network exposure.

### OSP.AUDIT
Security-relevant administrative activity is attributable, retained and protected.

### OSP.SECURE_UPDATE
Only authenticated/authorized update artifacts are accepted.

### OSP.SECURE_DEFAULTS
Production installation and reset states use a documented secure baseline.

### OSP.STORAGE_ISOLATION
Storage presentation/access is explicitly authorized and deny-by-default where technology permits.

### OSP.NO_SECRET_LEAK
Secrets must not appear in ordinary logs, URLs, browser storage, source repositories or support artifacts.

### OSP.EVIDENCE_BEFORE_CLAIM
A control is not considered PASS until implementation, test and retained evidence exist.

### OSP.DATA_PATH_INDEPENDENCE
Management-plane outage or license state must not intentionally interrupt already-established storage I/O.

## 4. Operational Environment Assumptions

### A.PHYSICAL
The appliance is deployed in a physically controlled environment appropriate to enterprise storage.

### A.TRUSTED_NETWORK
Management, storage and hardware-management networks are segmented/restricted according to deployment guidance.

### A.ADMIN
Administrators are authorized, trained and follow security guidance; malicious-administrator risk is mitigated through separation, audit and policy rather than assumed away where possible.

### A.TIME
A trustworthy time source is available to the TOE.

### A.PKI
Where external PKI is used, trusted CA/certificate lifecycle services are correctly operated.

### A.DIRECTORY
Where AD/LDAP is used, the external directory is securely administered and reachable over approved protected channels.

### A.FABRIC
External FC switches/fabric enforce documented zoning and physical/logical segmentation.

### A.BACKUP
External backup repositories, if outside the TOE, are protected according to deployment policy.

### A.PLATFORM
The evaluated/supported OmniOS hardware/software baseline is deployed without unauthorized platform modification.

## 5. TOE Security Objectives

### O.IDAUTH
Identify/authenticate human and service principals before protected management access.

### O.AUTHZ
Enforce role, function, object and scope authorization server-side.

### O.SESSION
Protect session establishment, lifetime, rotation, revocation and browser-origin state changes.

### O.TRUSTED_CHANNEL
Protect management and relevant integration traffic against disclosure/modification/downgrade.

### O.AUDIT
Generate attributable security audit records for authentication, authorization, privileged actions, configuration, updates and security lifecycle events.

### O.AUDIT_PROTECT
Protect audit records against unauthorized alteration/deletion and preserve usable time/correlation context.

### O.INPUT
Validate untrusted input and prevent injection/command execution/path and parser abuse.

### O.SECRETS
Protect credentials, private keys, tokens and service secrets in storage, process boundaries, logs and exports.

### O.SECURE_STORAGE_CONTROL
Ensure storage mappings/exports/security profiles can be changed only through authorized policy-controlled operations.

### O.UPDATE
Verify update authenticity/integrity, enforce authorization and provide controlled failure recovery.

### O.INTEGRITY
Protect security-relevant configuration/software state against unauthorized modification and detect drift where applicable.

### O.RECOVERY
Protect recovery/snapshot/configuration state against unauthorized destruction and verify restoration capability.

### O.RESOURCE
Bound management/API resource consumption sufficiently to preserve administrative availability.

### O.SAFE_FAILURE
Fail closed for authorization/security decisions while preserving safe independence from the storage data path.

### O.SECURE_DEFAULT
Ship/deploy with the documented secure configuration by default.

## 6. Environmental Security Objectives

### OE.PHYSICAL
Provide controlled physical access and appropriate power/environmental protection.

### OE.NETWORK
Provide segmentation/firewalling for management, storage and BMC networks.

### OE.FABRIC
Configure FC zoning and external switch security according to INPSan deployment guidance.

### OE.TIME
Provide reliable time synchronization.

### OE.PKI_DIRECTORY
Securely operate external PKI/directory services when used.

### OE.PLATFORM
Maintain the supported OmniOS/hardware/firmware baseline and vendor-supported update posture.

### OE.ADMIN
Follow administrator guidance, change-control and incident-response procedures.

### OE.EXTERNAL_BACKUP
Protect external backup/replication targets when those controls are outside the TOE.

## 7. Initial threat-to-objective traceability

- T.AUTH_BYPASS -> O.IDAUTH, O.SESSION
- T.CREDENTIAL_ATTACK -> O.IDAUTH, O.SECRETS, O.AUDIT
- T.PRIV_ESC -> O.AUTHZ, O.AUDIT
- T.WEB_API_ATTACK -> O.INPUT, O.AUTHZ, O.SESSION, O.RESOURCE
- T.MGMT_CHANNEL -> O.TRUSTED_CHANNEL
- T.CONFIG_TAMPER -> O.AUTHZ, O.INTEGRITY, O.AUDIT
- T.AUDIT_TAMPER -> O.AUDIT_PROTECT
- T.UPDATE_COMPROMISE -> O.UPDATE, O.INTEGRITY
- T.SUPPLY_CHAIN -> O.UPDATE, O.INTEGRITY
- T.STORAGE_UNAUTH -> O.SECURE_STORAGE_CONTROL, OE.FABRIC, OE.NETWORK
- T.STORAGE_ADMIN_ABUSE -> O.AUTHZ, O.AUDIT, O.RECOVERY
- T.SNAPSHOT_RECOVERY_ATTACK -> O.RECOVERY, O.AUTHZ
- T.SECRET_DISCLOSURE -> O.SECRETS
- T.TIME_EVIDENCE -> O.AUDIT_PROTECT, OE.TIME
- T.PLATFORM_EXPOSURE -> O.SECURE_DEFAULT, O.INTEGRITY, OE.PLATFORM
- T.HARDWARE_MGMT -> O.SECRETS, O.TRUSTED_CHANNEL, OE.NETWORK
- T.DOS_MGMT -> O.RESOURCE
- T.MISCONFIGURATION -> O.SECURE_DEFAULT, O.SECURE_STORAGE_CONTROL, O.AUDIT
- T.DEPENDENCY_FAILURE -> O.SAFE_FAILURE, OE.PKI_DIRECTORY, OE.TIME

## 8. Next traceability step

Map each TOE objective to candidate CC SFRs and to the INPSan 3.3 Security Requirements Matrix. No SFR conformance claim is final until the evaluated configuration and laboratory requirements are frozen.
