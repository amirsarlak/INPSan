# INPSan Login v6 P0 — Candidate Handoff

Date: 2026-11-22
Parent checkpoint: INPSAN-SECURITY-POSTBOOT-CP-001
Release artifact: `INPSan-Login-UX-Fix-v6-P0-Candidate-20261122-OmniOS.tar.gz`
SHA256: `7453b779fb739671de62151dfe523e15380da6f1d86d3a8bcd0d3e73a5271807`
Status: **OFFLINE PASS / LIVE STAGE NOT PERFORMED**

Changes:
- Login-only generic invalid password and temporary lock messages above Submit, without changing Guard r2 logic.
- Responsive CSS fixes: no intentional hiding of product text below 900px; scroll-safe and no horizontal overflow in eight viewport tests.
- Login brand pixels and Persian caption from the approved v5 reference artwork (raster excerpt; vector master pending).
- Favicon on Login via versioned PNG, client-side browser title/tab update.

Offline validation:
- Reconstructed admin.pl: r3-r9 + v3 + v5 + Auth Guard r1 + Trusted Edge r2.
- Strict surgical patch and AuthGuard r2 hooks verified.
- Preflight, dry-run, stage, activate, verify and byte-identical rollback PASS in a fixture.
- Chromium static layout PASS at 320, 390, 610, 768, 900, 1024, 1366, 1920 widths.
- No live OmniOS/browser acceptance has been performed.

Not in P0: root initialize Web-UI splash, Security Center auth audit/log out event, first-boot wizard, MFA, certificate trust, password/session security modernization. These are distinct follow-on work packages.

Deploy guidance: **STAGE ONLY**, review results before activation. No ZFS, STMF, COMSTAR, Nginx, IP Filter or SMF changes.
