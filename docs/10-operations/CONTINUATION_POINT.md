# INPSan Continuation Point

Checkpoint time: `2026-09-28`  
Primary reference checkpoint: `CP-SEC-001`  
Parent strategic checkpoint: `CP-KB-001`

## Immediate product-development objective

Continue **WP-3.3-003 — Security Architecture & Certification-Readiness Baseline** from the newly created TOE/PP/SPD/ST evaluation foundation.

The next active engineering task is:

**Build the SFR-to-INPSan implementation/test/evidence traceability baseline, then implement the independent Control Plane identity/AuthN/RBAC/audit security foundation before any production state-changing endpoint is accepted.**

## Active 3.3 security artifacts

- `docs/05-work-packages/WP-3.3-003-SECURITY-CERTIFICATION-BASELINE.md`
- `docs/11-security/TOE_BOUNDARY_V0.1.md`
- `docs/11-security/PP_APPLICABILITY_ANALYSIS_V0.1.md`
- `docs/11-security/SECURITY_PROBLEM_DEFINITION_V0.1.md`
- `docs/11-security/SECURITY_TARGET_SKELETON_V0.1.md`
- `docs/11-security/SECURITY_ARCHITECTURE_V1.md`
- `docs/11-security/CONTROL_PLANE_SECURITY_CONTRACT_V1.md`
- `docs/11-security/SECURITY_HARDENING_BASELINE.md`

## Immediate 3.3 execution sequence

1. Derive candidate CC SFRs from the Security Target skeleton.
2. Map SFR -> INPSan component -> 3.3 security control -> test -> evidence.
3. Freeze security-critical Control Plane interfaces.
4. Implement named local identity/authentication foundation.
5. Implement capability-based RBAC and object/scope authorization.
6. Implement security audit schema and protected evidence path.
7. Implement secure command/storage adapter; prohibit unsafe shell concatenation.
8. Add TLS/session/input-validation baseline.
9. Execute negative authorization and Web/API security tests.
10. Only then permit state-changing Control Plane endpoints.
11. Proceed to FC/iSCSI/NFS/SMB policy enforcement.
12. Implement signed update/SBOM/SAST/SCA/DAST release-security gates.
13. Prepare independent penetration test and evaluation evidence package.

## Evaluation status

Working TOE:
`INPSan Secure Storage Management Appliance — Single-Node 3.3 Evaluation Candidate`

Current PP position:
- no unsupported Protection Profile conformance claim;
- CC:2022/CEM:2022 Security Target approach is the working evaluation structure;
- final AFTA PP/product category/assurance package remains subject to assigned-laboratory confirmation.

## Security acceptance rule

No control is PASS without:
1. implementation;
2. deterministic verification;
3. retained version-bound evidence.

No production state-changing Control Plane endpoint is accepted before AuthN, RBAC, audit, TLS, input validation, secrets handling and negative authorization tests meet the Control Plane Security Contract.

## Frozen operational baseline and unresolved production RCA

The validated 3.2.x operational line remains frozen and must not be destabilized by 3.3 work.

The previously accepted ARC stabilization remains in force:
- persistent `zfs_arc_max = 17179869184` (16 GiB);
- runtime verification previously PASS;
- all pools healthy in the accepted sample;
- no intentional production `savecore` re-test.

The Aug 05 H240/`smrt` kernel panic remains a separate high-risk driver-path RCA:
- do not intentionally reproduce disk removal/reset conditions on production while the RCA is open;
- preserve the existing crash evidence;
- aggressive physical-bay removal/reinsert testing remains gated by the driver-risk review.

Outbound notification channels remain disabled until separately accepted.

## Development branch

`feature/inpsan-3.3-engineering-foundation`

All 3.3 security/evaluation work continues on this branch or controlled child branches; accepted 3.2.x production baselines are not modified directly.
