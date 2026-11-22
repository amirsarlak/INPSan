# INPSan Login Security UX v6.1.2 — Source Compatibility Candidate

Date: 2026-11-22
Parent checkpoint: INPSAN-SECURITY-POSTBOOT-CP-001
Source probe: both live `admin.pl` trees SHA256 `2176edeb2b14207d14f91ac206fba71c96964ac78ea8df4fc26641cbbd5b6ee4`
Prior v6.1 and v6.1.1 stopped at Preflight; neither was staged.

## Diagnosis
The live dashboard action dispatch marker, Login v6 P0 and AuthGuard Trusted Edge r2 exist, but the installer-expected `inpsan-dashboard-v3.1.13/dashboard.pl` module path and matching comment do not. Fixed-name module was not necessary for adding an authenticated Security Center route and was an overrestrictive source contract.

## New gated candidate
Archive `INPSan-Login-Security-UX-v6.1.2-Compat-Candidate-20261122-OmniOS.tar.gz`
SHA256 `83fe65e851b64d643773c41d0aea731111d6be40a999df03edf0003ba0535f62`

- Source hash pin to the exact observed live CGI version; both trees checked. Reject source drift.
- Structural source check: one Dashboard route, authenticated `getid()` before menu/dispatch, route between menu/preloads and explicit log-end/exit.
- Retains v6.1.1 Login CGI buffering/303 response, login feedback fixes, transparent approved raster brand image, responsive/favicons, admin-only read-only Audit Logs, 5-step review-only Wizard, informational legacy logout telemetry, HTTPS root redirect.
- Fail-closed contracts for established AuthGuard r2 and existing Nginx Trusted Edge.
- **No live OmniOS installation yet.** Offline Nginx fixture tests with renamed Dashboard module path: Preflight, Dry-run, Stage, Activate, Verify, Rollback all passed. Reverted original CGI SHA byte-identically. Packaging USTAR SHA-verified.

## Acceptance boundaries
Stage only on real appliance, with root SSH and version pin. On live preflight failure do not weaken/override source contract: inspect surrounding Dashboard route and correct adaptively. Post-activation needs real browser login failure/success, no dashboard flash, responsive/branding, Security Center access/role denial, Wizard, logout audit, Nginx/Firewall checks.
No MFA/OTP, real security settings mutation, trusted CA, session KDF rewrite in candidate.
