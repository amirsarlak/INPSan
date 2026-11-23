# INPSan WebGUI P1.5 — Header and Dialog Hardening Candidate
Date: 2026-11-23
Status: OFFLINE QA PASS / LIVE INSTALLATION AND BROWSER ACCEPTANCE PENDING

## Operator-reported P1.4 issues
- Logout button visible before enhancement, missing after enhancement
- Header and Sidebar lose alignment during long Dashboard scroll
- Noticeable login and page navigation delays; cause unknown
- Native menu and header overlap before JS enhancement settles
- Vendor Pools properties dialog (`rpool:sync`) renders partly behind left sidebar

## Release
- `INPSan-WebGUI-Header-Dialog-Hardening-P1.5-Candidate-20261123-OmniOS.tar.gz`
- SHA256: `8a7e13ae762f9c1e8c306829e753565457ebf8f10ec5dd09ae3cc71a725c8fec`
- USTAR gzip; read-only probe/preflight/dry-run, stage, activate, verify, rollback, status
- Candidate MUST be applied on exact P1.4 active SHA baseline, P1.2 active, P1.3 rolled_back.

## Scope
- Four CSS/menu-version paired assets only (both `data` and `data_22.03`).
- Appends scoped rules for viewport-fixed `#header` with 72px flow compensation, Sidebar align, visibility of original `#topmenu > a:first-of-type` (without replacing logout URL/actions).
- Adds scoped CSS constraints for known vendor dialog classes `.ui-dialog`, `.jqmWindow`, and `[role=dialog]` on body-level popups; avoids unknown popup DOM mutations.
- Preserves original `navigation.js`, dashboard renderer, login/auth, CGI, Nginx, IPF, ZFS, STMF, FC and COMSTAR.
- Includes optional read-only browser DOM/performance diagnostics that never report session URLs or form data.

## QA
- Reconstructed r3-r9 -> P0 -> P1 -> P1.1 rollback -> P1.2 -> P1.3 rollback -> P1.4 -> P1.5 test cycle PASS.
- Stage no changes, activate + verify PASS; tamper refusal PASS; rollback restores byte-identical P1.4 CSS/menu PASS.
- Chromium fixture widths 1440/1024/768/390/320, initial Sidebar enhancement, original logout visible, fixed Header/Sidebar alignment at scrollY 800/2100/2800, simulated body-level ui-dialog not behind Sidebar: PASS.
- CSS parser and diagnostic JavaScript syntax PASS.
- NOT VERIFIED on actual napp-it: real logout hidden ancestor, rpool:sync actual DOM/class, system login/CGI latency and FOUC. Those must not be claimed fixed.

## Operational gate
Stage-only instructions shipped; require operator preflight output before activation. Emergency rollback returns P1.4. Browser acceptance and timing diagnostics on HTTPS 8081. No claims of live server access or deployment.
