# INPSan Login & Security UX v6.1.4 — Candidate

Date: 2026-11-22
Parent accepted baseline: `INPSAN-SECURITY-POSTBOOT-CP-001`
Parent live candidate: v6.1.3, installed per operator-supplied screenshots (live SHA pin based on installer-proposed manifest; not independently fetched).

## Operator acceptance and feedback (v6.1.3)
- Accepted: login brand mark and Persian text, responsive behavior, removed dashboard flash, Authentication Audit UI, review-only five-step Wizard, login favicon.
- Remaining: account lock should explicitly say up to 5 minutes (and show immediately on fifth failure), old favicon after authentication, wizard has no choices, middle-screen company names need better corporate typography.

## Candidate contents
Artifact `INPSan-Login-Security-UX-v6.1.4-Followup-Candidate-20261122-OmniOS.tar.gz`.
SHA256 `4f1e738e6bc57c6864b64883c5bcad1102cf60f53cd0cccd23a92654d03f6b18`
Archive format USTAR.

- Explicit 5-minute policy message, immediate after 5th failed admin/operator password when Guard returns lock_until; account/credential privacy maintained.
- Favicon after login at DOMContentLoaded + load, cache-busted query version 614.
- Formal style uplift for corporate company-name typography using available local/fallback fonts; exact proprietary logo font **not included**.
- Security Wizard gains selectable choices with nonced POST, strict value whitelists and saved private administrative draft (4 sections + summary/explicit acknowledgement).
- **Crucial scope:** plan choices never apply live MFA, certificate, allowlist, password or session changes. UI labels each option as a future plan, and each step explicitly says review/draft-only.
- No direct modifications to Authentication Guard r2, Nginx, IP Filter, ZFS, STMF, COMSTAR, FC, SMF or telemetry.

## Live stage gate
Installer requires active state `/var/opt/inpsan/login-security-v613-20261122/active` AND each live file's SHA to match the matching entry in `proposed.sha256`. This will fail closed on drift; users must not override.
Use `--probe`, `--preflight`, `--dry-run`, `--stage`, `--status` first. No live activation until Stage reviewed.

## Offline QA completed
- Perl patch syntax and SecurityCenter.pm compile PASS.
- Patch on reconstructed v6.1.3 source, syntax of both CGI trees with test shim PASS.
- Linux fixture: `Preflight -> Dry-run -> Stage -> Activate -> Verify -> Rollback` PASS, original CGIs and SecurityCenter restored byte-identically.
- Wizard CSRF/option input validation, draft persistence, forced acknowledgement tests PASS.
- Chromium headless authenticated favicon replacement: width 390/1366 PASS.
- Responsive Wizard options: width 390/1366 no horizontal overflow PASS.
- Not yet tested live OmniOS user flows.

## Remaining project limitations
Directly applying security settings needs a privileged transactional broker with policy validation, staged apply, health checks and Rollback. Actual MFA/enrollment, trusted TLS certificate, legacy URL session removal, external notification delivery, and resilient nginx supervision remain out of scope.
