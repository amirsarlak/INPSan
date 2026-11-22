# INPSan Web GUI P1.1 — CSS-First Navigation Stability & Unified Surfaces

**Date:** 2026-11-22  
**Parent baseline:** INPSAN-WEBUI-VISUAL-REBASELINE-CP-002  
**Parent live UI:** Web GUI P1 visual sidebar (operator browser screenshot).  
**Release status:** Offline verified candidate; live OmniOS stage and acceptance PENDING.

## Motivation
Operator observed a flash of old horizontal napp-it menu when navigating between Dashboard, Pools, Disks, ZFS and COMSTAR before P1 sidebar appeared. P1 CSS is conditional on `body.inpsan-p1-ready` inserted by JavaScript at DOMContentLoaded, creating a first-paint gap. User also asked for unified page background, cards and typography, not only menus.

## Deliverable
- Artifact: `INPSan-WebGUI-Shell-Stability-P1.1-Candidate-20261122-OmniOS.tar.gz`
- SHA-256: `4f3a2f9af53e8d0b81e054b6dec8b68ee9b8f7ce3b466ac481bfe2077f4c9b39`
- USTAR gzip with installer `bin/inpsan-webui-p11`, P1.1 CSS payload, Persian README, QA scripts/previews and restore controls.
- Changes only **four** files: paired `brand.css` and paired `about_menus.txt`; `navigation.js`, `admin.pl`, Guard, Gateway, SMF, IP Filter, ZFS, STMF, COMSTAR, FC remain untouched.
- Require **P1=active**, source SHA match against P1 proposed manifest and exact menu asset cache refs; fail-closed if mismatch.
- Pre-JS menu is rendered in the Sidebar column using render-blocking vendor CSS and Chrome `:has()` selector; native links remain accessible if JS cannot enhance. On narrower viewports, native horizontal fallback is scrollable until the drawer loads.
- Additional authenticated surfaces and breadcrumb/table styles inherit approved branding `#081B36`, `#0A84FF`, `#00C2D4`, `#22C55E`.
- Version-busts only stylesheet link to `brand.css?v=20261122p11`. Original JS version references unchanged.

## Offline QA
- Bash syntax: PASS; CSS parser: PASS.
- Linux fixture rebuilt from P0 + P1 and tested `--preflight → --dry-run → --stage → --activate → --verify → --rollback`: PASS.
- Original parent P1 six-file manifest intact, all four patch files byte-identical after rollback: PASS.
- Chromium mock (Dashboard and Disks synthetic fixture), pre-/post-enhancement five screen sizes, 20/20 viewport checks PASS.
- Simulated delayed P1 JS injection (750 ms): 1440px, 1024px, 390px PASS: left fallback menu painted first, final P1 navigation accessible, no full-width horizontal desktop menu flash.
- These tests do NOT establish that vendor's actual page loads CSS before the first paint in every live browser. The real napp-it multi-level hover behavior, cache timings and JS errors require on-appliance browser acceptance.

## Live gate
Run `--probe`, `--preflight`, `--dry-run`, `--stage`, `--status` only. Review stage before activate; keep independent root SSH session. After activation, hard refresh and navigate among Dashboard, Pools, ZFS, Disks, COMSTAR. Use browser Network throttling to confirm the old menu no longer flashes. On failure `--rollback` restores P1. Do not perform mutating storage actions during visual smoke testing.

## Scope boundary
P1.1 is a shell stability/visual background patch, NOT full page-group P2 and NOT Security Configuration Backend. Legacy URL session identifier and TLS certificate trust issues remain open.
