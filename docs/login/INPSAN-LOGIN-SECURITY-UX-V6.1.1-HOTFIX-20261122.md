# INPSan Login Security UX v6.1.1 — gated source-contract and CGI response hotfix

Parent baseline: `INPSAN-SECURITY-POSTBOOT-CP-001`.

Operator stage attempt of v6.1 on 2026-11-22:
```
SOURCE CONTRACT FAILED: INPSan Dashboard Integration & Style Isolation v3.1.13
FAIL: unsupported CGI data/wwwroot/cgi-bin/admin.pl
Login v6.1 state: not staged
```
No live file modification was reported. This failure says the exact dashboard version comment was absent; it does not establish that the semantic Dashboard route exists.

Corrected artifact: `INPSan-Login-Security-UX-v6.1.1-Candidate-20261122-OmniOS.tar.gz`
SHA256: `de972d062cf92a43233a0ca94a8d7f6850020bc92a5943d386d05a0e86a54241`
Archive format: USTAR. Does not include bundled third-party CGI source.

Technical changes:
- Replace fragile exact dashboard comment anchor with strict structural checks of the handler, module location, menu ordering, and existing AuthGuard r2 markers.
- Repair v6.1 CGI response buffering: capture login GET and login POST **before** `Content-type` is printed; flush on all `exit` via `END`; replace response with strictly validated HTTP 303 after success.
- Add non-mutating `--probe` reporting hashes and contract marker presence only.
- Preserve existing approved logo, responsive assets, favicon, admin read-only Authentication Logs, first-login review wizard, legacy logout audit and Nginx root redirect.

Validation performed offline on reconstructed Login v6 P0 + AuthGuard Trusted Edge r2 fixture, NOT on operator's live CGI:
- Perl patch syntax passed; fixture with and without dashboard comment patched; CGI mock error/303 behavior passed.
- Full `--preflight → --dry-run → --stage → --activate → --verify → --rollback` on Linux test Nginx passed with byte-identical CGI restored.
- Live OmniOS stage remains pending. Fail closed if true Dashboard handler is absent.

Deploy guidance: `--probe`, `--preflight`, `--dry-run`, `--stage`, `--status` ONLY. Wait for verification before activating.

Do not use broken v6.1 or manually remove its source contract.
