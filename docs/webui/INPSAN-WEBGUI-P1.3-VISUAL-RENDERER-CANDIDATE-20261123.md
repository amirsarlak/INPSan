# INPSan Web GUI Visual Renderer P1.3 — Candidate

Date: 2026-11-23
Parent: INPSAN-WEBUI-VISUAL-REBASELINE-CP-002
Prior live operator evidence: P1.2 recovered header and content; navigation flash and failure to apply Dashboard style remained.
**Status: Offline QA PASS, NOT yet installed/verified on live OmniOS.**

## Package
- `INPSan-WebGUI-Visual-Renderer-P1.3-Candidate-20261123-OmniOS.tar.gz`
- SHA256: `d7caa56adf767a56f7385b3d5ae3c37389f9e0d0475ec0f2a2a055a5dce7567c`
- Format: USTAR gzip
- Installer: `bin/inpsan-webui-p13`, with `--probe --preflight --dry-run --stage --activate --verify --rollback --status`.

## Technical correction
P0 styled the retired `#inpsan-live-dashboard` and v3.1.13 CSS; active renderer is v3.2.1 `#inpsan-historical-dashboard`, as confirmed by live operator `grep` and existing source inspection. P1.3 adds a higher-specificity overlay in paired `brand.css`, targeting the actual current DOM without overwriting or changing the vendor `dashboard.css` or Perl dashboard renderer. Vendor component names checked via read-only Preflight.

Prior P1.1 changed header/content geometry before JS and caused clipping and disappeared logo. P1.2 restored geometry. P1.3 leaves P1.2 geometry alone, and implements a 2.1-second finite CSS prepaint curtain for the legacy navigation/content while the DOMContentLoaded Sidebar is being constructed; native UI reappears automatically if JS fails (CSS `:has` support dependent). On supported browsers with styles arriving before first paint this reduces the old-menu flash. It does NOT guarantee zero FOUC across all configurations.

## Fail-safe change boundary
- Only four files changed: paired `data/data_22.03` copies of `wwwroot/_my/inpsan-brand-v3.1.13/brand.css` and `napp-it/zfsos/_lib/lang/en/about_menus.txt`.
- Must have `P1=active` and `P1.2=active`, with all four file hashes matching P1.2 proposed SHA manifest.
- Checks live Dashboard `dashboard.pl` and `dashboard.css` structural markers for version v3.2.1.
- Stages SHA256 backup/proposals; refuses unreviewed drift on activate/rollback.
- Does NOT change CGI, Authentication Guard, Security Center, Nginx, IP Filter, SMF, ZFS, FC, COMSTAR, STMF or collector data.
- Confirmed separate network test on 2026-11-23: client 10.0.0.33 to 172.25.25.48 TCP81 failed and TCP8081 succeeded; root cause of temporary IPv4 IPF rule loss remains open.

## Offline test results
- Local source fixture: r3-r9 → P0 → P1 → P1.1 → P1.1 rollback → P1.2 → P1.3 stage/activate/verify/rollback **PASS**.
- External source drift refusal: **PASS**.
- Byte-identical return to P1.2 for four patched files: **PASS**.
- Chromium with actual preserved v3.2.1 CSS and representative DOM at 1440/1024/768/390/320: **5/5 PASS**. Artificial delayed JavaScript shows prepaint hidden and final sidebar with header/logo visible; current-dashboard white module surfaces verified. No JavaScript -> fallback visible at ~2.1 s.
- Browser previews are synthetic, NOT live SAN values.

## Next acceptance gate
Run only `--probe --preflight --dry-run --stage --status` on the appliance and inspect output. Activation after review, SSH session available. Test on HTTPS8081, Dashboard, Disks, Pools, ZFS, COMSTAR, responsive windows and transition timing; do not claim P1.3 accepted until operator verifies screenshots.
