# INPSan Login & Security UX v6.1.3 — Favicon Source-Contract Hotfix
Date: 2026-11-22
Parent: INPSAN-SECURITY-POSTBOOT-CP-001
Prior: v6.1.2 Preflight aborted — `Expected exactly one global favicon, found 0`; state NOT STAGED.

## Live operator evidence
Both `admin.pl` trees remain SHA256 `2176edeb2b14207d14f91ac206fba71c96964ac78ea8df4fc26641cbbd5b6ee4`. Login v6 P0 and Trusted Edge AuthGuard r2 markers present. Nginx configuration syntax passed. No production source changed in v6.1.2.

## Hotfix
Removes brittle exact two-line vendor CGI header comment anchor used to inject the authenticated favicon. Attaches a static, self-contained JS icon update to the already validated, post-`getid()`, pre-Dashboard authenticated dispatch location. Keeps strict structural Source Contract and exact live CGI SHA pin, preserves all v6.1.2 UX + Security Center features.

## New artifact
`INPSan-Login-Security-UX-v6.1.3-Compat-Candidate-20261122-OmniOS.tar.gz`
SHA256: `b48950c7aab1f53e8bc478b0bf631765397cc79c8f56ebf86ced806411e83077`
Packaging: USTAR. Does not include vendor CGI binaries/source.

## Offline QA
Reconstructed v6 P0 + AuthGuard r2 fixture with expected header anchor deliberately removed: Perl `-c` for full patched CGI PASS, Nginx config PASS, real local Nginx `Preflight → Dry-run → Stage → Activate → Verify → Rollback` PASS, two CGI trees restored byte-identically (SHA256 `702f03cb9dd96dd9db07294f204582e79eced98f3ee7ae16a794d175d1afe361`). This is NOT live OmniOS acceptance.

## Live activation gate
Run `--probe`, `--preflight`, `--dry-run`, `--stage`, `--status` ONLY on appliance; preserve root SSH, do not override hash guard. No previous candidate v6.1/v6.1.1/v6.1.2 was staged. Login error, 303 redirect, Security Center, wizard and logout all require on-host acceptance before activation is considered validated.

No ZFS, STMF, COMSTAR, FC, firewall, IP Filter, SMF or authentication policy changes.
