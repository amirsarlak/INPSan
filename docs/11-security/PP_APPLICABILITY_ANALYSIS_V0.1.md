# INPSan Protection Profile Applicability Analysis v0.1

Status: **DRAFT — NO CONFORMANCE CLAIM**  
Date: 2026-09-28  
Parent: `WP-3.3-003`

## 1. Purpose

Determine which international security-evaluation profiles and standards are applicable to INPSan without forcing the product into an unrelated Protection Profile.

## 2. Product characterization

Working category:

**Secure enterprise storage management appliance / SAN-NAS management and security product layer**

Foundation:
- OmniOS / illumos;
- OpenZFS;
- COMSTAR/STMF;
- supported storage/network services.

Proprietary/evaluated focus:
- management plane;
- identity/RBAC/session security;
- audit;
- secure storage-control workflows;
- Web/API;
- secrets/certificates;
- secure update/integrity;
- storage-security policy/monitoring.

## 3. Applicability conclusions

### 3.1 Common Criteria CC:2022 / CEM:2022
**Applicability: DIRECT / REQUIRED AS EVALUATION STRUCTURE**

Use for:
- TOE definition;
- Security Target structure;
- Security Problem Definition;
- security objectives;
- SFR/SAR selection;
- TOE Summary Specification;
- evaluator evidence and traceability.

Current decision:
- use immediately as the evaluation-document framework;
- no EAL/assurance claim until laboratory confirmation.

### 3.2 Dedicated SAN/NAS Storage Appliance PP
**Applicability: NOT IDENTIFIED AS A SINGLE DIRECT MATCH IN CURRENT INTERNATIONAL BASELINE**

Current decision:
- do not claim conformance to a generic SAN/NAS PP unless the assigned laboratory identifies a mandatory national or international profile;
- use ST-based requirements plus applicable PP-derived controls where permitted.

### 3.3 Storage / Full-Drive / Data-at-Rest Encryption PPs
**Applicability: PARTIAL / FEATURE-SPECIFIC**

Relevant only where the evaluated claim is specifically:
- encrypted storage;
- self-encrypting media;
- data-at-rest encryption;
- key management.

They do not, by themselves, cover the full INPSan management, RBAC, audit, SAN/NAS and Web/API product scope.

Decision:
- reuse relevant encryption/key-management concepts;
- do not claim whole-product conformance unless the evaluated target is deliberately narrowed to encryption.

### 3.4 Network Device cPP concepts
**Applicability: PARTIAL / CONTROL REUSE, NOT CURRENT CONFORMANCE CLAIM**

Relevant concepts include:
- secure administration;
- trusted channels;
- identification/authentication;
- audit;
- update integrity;
- protection of credentials;
- self-protection.

Mismatch:
- INPSan is primarily a storage-management/storage-control appliance, not a general-purpose network infrastructure device.

Decision:
- reuse applicable SFR/control concepts;
- do not claim NDcPP conformance without laboratory confirmation.

### 3.5 Application/Web security standards
Not Protection Profiles, but mandatory engineering baselines:
- OWASP ASVS 5.0 Level 2 default;
- selected ASVS Level 3 controls for high-impact administration;
- OWASP WSTG for verification;
- OWASP API Security Top 10 for API abuse/authorization coverage.

### 3.6 Storage-security standards
Not CC Protection Profiles, but mandatory storage-security design baselines:
- ISO/IEC 27040:2024;
- NIST SP 800-209 final;
- NIST SP 800-209 Rev.1 IPD only as forward-looking guidance until finalized.

## 4. Proposed conformance strategy

Until the AFTA laboratory confirms a mandatory PP:

1. Build a rigorous CC:2022-oriented Security Target.
2. Select SFR families based on the actual INPSan TOE.
3. Map each SFR to:
   - INPSan component;
   - implementation;
   - deterministic test;
   - retained evidence.
4. Use ISO 27040/NIST 800-209 to ensure storage-specific threats and controls are not missed.
5. Use ASVS/WSTG/API Security for the management Web/API attack surface.
6. Tailor final claims to the assigned laboratory requirements.

## 5. Candidate SFR families for detailed selection

Likely relevant:
- `FAU` — Security Audit;
- `FCS` — Cryptographic Support;
- `FDP` — User Data Protection where TOE policy directly controls protected storage objects/metadata;
- `FIA` — Identification and Authentication;
- `FMT` — Security Management;
- `FPT` — Protection of the TSF;
- `FTA` — TOE Access / session controls;
- `FTP` — Trusted Path/Channels;
- applicable resource/availability components only where an explicit TOE security claim is made.

Final component/operation/assignment/selection decisions belong in the Security Target after the TOE and laboratory profile are frozen.

## 6. Assurance areas that must be planned

Regardless of final assurance level:
- functional specification/interface description;
- architecture/design description;
- administrator/user guidance;
- lifecycle/build/configuration management;
- delivery/update integrity;
- developer testing;
- independent testing support;
- vulnerability analysis;
- evidence reproducibility.

## 7. Laboratory confirmation checklist

Before certification freeze, obtain written confirmation of:
- official product category;
- mandated PP/cPP or permission for ST-based evaluation;
- assurance package/EAL or national equivalent;
- cryptographic evidence expectations;
- vulnerability-analysis methodology;
- penetration-test scope;
- source-code review expectations;
- required secure configuration;
- permitted dependencies in operational environment;
- required evidence formats;
- rules for third-party/open-source components.

## 8. Decision

**Current INPSan 3.3 strategy: CC/ST-based evaluation foundation with storage-specific and Web/API security controls, while keeping PP conformance OPEN until the assigned AFTA laboratory confirms the applicable profile.**

This avoids both under-scoping and an unsupported claim of conformance to an unrelated PP.
