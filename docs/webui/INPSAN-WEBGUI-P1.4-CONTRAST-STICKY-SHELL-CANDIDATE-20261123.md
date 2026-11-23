# INPSan WebGUI P1.4 — Contrast and Sticky Shell Candidate

Date: 2026-11-23
Status: OFFLINE QA PASS / LIVE QA PENDING
Baseline: P1 active, P1.2 active, rejected P1.3 rolled_back.
Previous candidate: P1.3 rejected by operator for mixed white/dark contrast, visible loading curtain, and white gap above fixed sidebar when scrolling.

## Release artifact
File: `INPSan-WebGUI-Contrast-Shell-P1.4-Candidate-20261123-OmniOS.tar.gz`
SHA-256: `f9b0112a9fe7b6b90ad2b1b3088f15ae49edafbc12d4400b9847470a0549139d`
Format: USTAR gzip; includes self-checking installer, patch, Persian README, QA and preview artifacts.
Installer: `bin/inpsan-webui-p14`.
State path on OmniOS: `/var/opt/inpsan/webui-contrast-shell-p14-20261123`.

## Scope
- Forces clean P1.2 baseline, P1.3 rolled_back, exact SHA match of four UI assets.
- P1.3 CSS removed, so no `Preparing management console` overlay and no forced pre-JS content hiding. P1.2 native-menu fallback remains.
- Current Dashboard v3.2.1 `#inpsan-historical-dashboard.inpsan-ia-shell` uses fully dark contrast: fixed module, metric tiles and status text are styled together. No dangerous operation workflows changed.
- After P1 JS enhancement, `#header{position:sticky;top:0}` aligns with Sidebar fixed at 72px, preventing exposed light gap on scroll. P1 original logo/content geometry retained.
- Only paired `data` and `data_22.03` brand.css and about_menus.txt changed, cache key `20261123p14`. Navigation JS remains unchanged.
- No modifications to Nginx, HTTP81/IPF, SMF, AuthGuard, perl/CGI, Dashboard renderer, ZFS, STMF, FC, COMSTAR, data pools, or underlying system.

## Offline QA results
- Fixture path: r3-r9 -> P0 -> P1 -> P1.1 -> P1.1 rollback -> P1.2 -> P1.3 active -> P1.4 refusal -> P1.3 rollback -> P1.4 preflight, dry-run, stage, activate, verify, drift rejection, rollback: PASS.
- Byte-identical return to P1.2: PASS.
- CSS parser: no syntax errors.
- Chromium synthetic Dashboard/Disks: 10/10 viewport cases 1440/1024/768/390/320 PASS; initial native menu visible and functional; no preload overlay; logo present; sticky header at top0 and sidebar top72 after scrollY850; no document horizontal overflow; mobile toggle and Escape tested.
- Contrast tokens for nested cards: >=7:1 on tested backgrounds. Full live Dashboard variant QA not yet completed.
- USTAR extraction and SHA256SUMS verification: PASS.

## Limitation
P1.4 does **not** guarantee zero FOUC across real napp-it HTML load timing; native menu could appear before P1 JS completes. Definitive cure may require a separate audited HTML-head critical CSS/bootstrap implementation. Browser/source fixture tests are not actual on-host acceptance.

## Next live gate
Operator should rollback P1.3, then run P1.4 --probe, --preflight, --dry-run, --stage, --status. If pass, SSH session preserved, run --activate, --verify, --status; test live HTTPS8081 dashboard, Pools/COMSTAR, 1366px/mobile, scroll, dynamic menus, clear cache. Can --rollback P1.4 if there is regression. No further approval required to proceed with development and package construction, but no claim of remote deployment without operator outputs.
