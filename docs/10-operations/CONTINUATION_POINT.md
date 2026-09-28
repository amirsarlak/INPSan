# INPSan Continuation Point

Checkpoint time: `2026-09-28`  
Primary reference: `CP-SEC-004`  
Parents: `CP-KB-001 / CP-SEC-001 / CP-PD-001`

## Current execution state

Final integrated 3.3 roadmap is approved and operations have started.

### Completed design/evaluation baseline
- product boundary and knowledge-based doctrine;
- TOE Boundary v0.1;
- PP Applicability Analysis v0.1;
- Security Problem Definition v0.1;
- Security Target Skeleton v0.1;
- candidate SFR Traceability Baseline;
- AFTA/passive-defense alignment baseline;
- human-owned UX/experience-driven operations requirements;
- final execution gates.

### Security implementation status
- S0 Evaluation Foundation: PASS (design baseline)
- S1 Independent Identity/AuthN: PASS — live OmniOS validation accepted
- S2 RBAC/Object-Scope Authorization: PASS — live role and cross-pool scope evidence accepted for single-node baseline
- S3 Security Audit Plane: PARTIAL — schema, runtime audit, hash-chain and tamper detection PASS; retention/rotation/capacity/export/benchmark remain open
- S4 Session/TLS/Secrets: OPEN
- S5 Secure Operation Broker: OPEN
- S6 Storage Protocol Security: OPEN
- S7 Secure Update/Supply Chain: OPEN
- S8 Security Verification/Pentest: OPEN

## Active code baseline

Branch:
`feature/inpsan-3.3-engineering-foundation`

Current development components:
- `src/control-plane/lib/INPSan/Security/Auth.pm`
- `src/control-plane/lib/INPSan/Security/RBAC.pm`
- `src/control-plane/inpsan-control-plane-v0.2.1-dev.pl`
- `src/control-plane/inpsan-useradd-v0.2.0-dev.pl`
- `src/control-plane/verify-auth-v0.2.sh`
- `src/control-plane/verify-rbac-v0.2.1.sh`

## Immediate next operations

1. Execute SEC-IMP-01 live OmniOS validation and retain sanitized evidence.
2. Execute live HTTP negative authorization tests for all initial roles.
3. Execute live allow/deny tests for pool-specific scopes.
4. Implement audit retention/rotation/capacity health and protected audit query/export.
5. Prepare live OmniOS evidence for AuthN/RBAC/Scope/Audit.
6. Continue Session/TLS/Secrets after the current security line is stable.
7. Do not add production state-changing storage endpoints before S1-S5 gates pass.

## Parallel mandatory workstreams

In parallel:
- UX Design System / personas / customizable workspace;
- benchmark/resource-efficiency framework;
- local predictive intelligence data-quality foundation;
- Central Manager architecture;
- licensing/product governance;
- operational/RCA closure;
- knowledge-based evidence package.

Each new work item must state:
- product/operational purpose;
- knowledge-based/R&D evidence;
- AFTA/security applicability;
- passive-defense/resilience impact;
- UX/operator impact;
- performance/resource impact;
- test/evidence output.

## Production safety

The validated 3.2.x operational line remains frozen.

H240/smrt high-risk RCA restrictions remain in force for destructive hardware tests.

Outbound notification channels remain disabled until independently accepted.

PASS = implementation + deterministic test + retained version-bound evidence.


## Live validation references

- `src/control-plane/live-validate-security-v0.2.2.sh`
- `docs/08-testing/LIVE-SECURITY-VALIDATION-V0.2.2.md`

Execution command from `src/control-plane`:

`bash live-validate-security-v0.2.2.sh`

Expected evidence directory:
`/var/tmp/inpsan-sec-live-YYYYMMDD-HHMMSS/`
