# INPSan Login & Security UX v6.1 Candidate — 2026-11-22

Parent accepted checkpoint: `INPSAN-SECURITY-POSTBOOT-CP-001`, commit `f38770e525e2249dea910434c50a56a097d6e1e8`.

Artifact: `INPSan-Login-Security-UX-v6.1-Candidate-20261122-OmniOS.tar.gz`.
SHA256: `bc508f046753d04fc4e277ffe701002facb934e949371e0a03dbf4d83895bec5`
Format: USTAR, excludes vendored napp-it source.

Status: **offline PASS; live OmniOS Stage/Accept pending**.

Scope:
- Correct Perl lexical-variable login error handling (fixed internal reason, no user enumeration).
- Buffer initial login GET and login POST so legacy header/dashboard chrome cannot stream before the auth outcome; use CGI 303 after successful login.
- Nginx root `/` and `/index.html` redirect only to `/cgi-bin/admin.pl`, retaining Trusted Edge cookie forwarding.
- Pixel-preserving transparent approved v6 brand logo, versioned favicon in login and authenticated UI, responsive CSS tested at eight viewport sizes.
- Authenticated admin-only `Security Center`: view actual AuthGuard JSONL (escaped, read-only, paginated).
- Five-step first-login *review* wizard, explicit acknowledgement with per-session nonce, no policy mutations.
- Legacy logout session removal audit with `source_verified=false` (not a verified user logout claim).

Offline evidence: Perl syntax of patched full reconstructed `admin.pl` with shims; Nginx 1.26.3 config syntax and reload with 302 root behavior; stage/activate/verify/rollback and byte-identical recovery in fixture; Chromium 320..1920 width no horizontal overflow; audit escaping and wizard nonce and operator-denial tests.

Not certified: Live OmniOS CGI 303 behavior, real browser login/error, logged out telemetry, authenticated UI and wizard. NO MFA, provider notification, session cookie/KDF upgrade, or TLS certificate trust in this release. No ZFS/STMF/FC/IP Filter/SMF changes.

Deployment gate: **preflight, dry-run, stage, status only until reviewed.** Keep independent SSH and validated credentials. Activate separately, run login success/failed with controlled attempts, and rollback on errors. Prior v6 P0 + AuthGuard r2 + HTTPS Gateway r2 are strict preconditions.
