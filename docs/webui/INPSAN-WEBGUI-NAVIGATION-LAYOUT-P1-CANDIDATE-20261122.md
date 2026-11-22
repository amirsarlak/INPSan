# INPSan Web GUI Navigation & Layout P1 — 2026-11-22 Candidate

Parent: `INPSAN-WEBUI-VISUAL-REBASELINE-CP-002` (Commit `973cebc706064d11279599005475ea7306b15973`).
Production accepted baseline: Login/Security UX v6.1.4 + Web GUI P0 visual overlay.
**Status: offline QA PASS; live OmniOS not staged nor accepted.**

## Artifact
`INPSan-WebGUI-Navigation-Layout-P1-Candidate-20261122-OmniOS.tar.gz`
SHA256: `b4402da765a777b5d159e072a67c8f9aafebc86a154a496ba62abc358a9ea4df`
Format: USTAR.

## Technical design
- Uses actual approved INPSan P0/nav v3.1.13 source; updates **six files**: paired `brand.css`, paired `navigation.js`, paired `napp-it/zfsos/_lib/lang/en/about_menus.txt`.
- Adds a separate JS IIFE reading only **currently present, visible** original menu entries after native `initNavigation()`; builds a responsive Sidebar with nested details, keyboard toggling, search filter, overlay and Escape close.
- Menu `href` and handlers are preserved. For links with an existing JS/onClick handler, the sidebar delegates the real user interaction to the original menu anchor; backend actions are not reimplemented.
- Original menu is retained in DOM. P1 styles are gated on a successful `body.inpsan-p1-ready`; a missing/unsupported menu falls back to old horizontal UI.
- Updates existing CSS+JS reference querystrings in `about_menus.txt` for cache invalidation, no added external dependency.
- Card/shell background and branding follows approved palette `#081B36 #0A84FF #00C2D4 #22C55E`. Accessible sidebar, fixed desktop/sidebar, mobile drawer.
- Operational pages retain original route/rendering; table spacing/scroll improved without executing storage operations.
- **No change** to `admin.pl`, `SecurityCenter.pm`, Guard r2, storage collectors, backend, Nginx, IP Filter, SMF, ZFS, FC, COMSTAR or STMF.

## Fail-closed source contract
- Require existing P0 state `active` and SHA match against P0 proposed manifest.
- Recognize source `navigation.js` SHA256 `97fe103eaf5694dd049914223bfcc8e3e72cdd4a75e098674fb5ace10058bde0` and menu file SHA256 `b4c9b8e7ba9e2d8528d701c21c87d717c10fe7a230e84891db076db62e14298b`, both trees identical.
- Require the vendor CSS, nav and menu references and refuse live or staged file drift.
- Installer has `--probe`, `--preflight`, `--dry-run`, `--stage`, `--activate`, `--verify`, `--rollback`, `--status`.

## Offline acceptance
- Linux source fixture cycle Preflight → Dry-run → Stage → Activate → Verify → Rollback PASS; original files byte-identical restored.
- Source-drift/duplicate-stage rejection PASS; merged JS and Bash syntax PASS.
- Chromium static synthetic Dashboard + Disks demo: 10/10 viewport checks (1440, 1024, 768, 390, 320 px), no body overflow, sidebar/drawer/focus tested. Search filtering, nested submenu toggling, missing-menu safe fallback PASS.
- **Not yet tested:** real live napp-it multi-level submenus, storage action forms, dynamic menu payload, real Security Center, legacy command bar.
- Sample preview images use synthetic data, not live SAN.

## Phase P2
Once on-appliance UI and functional acceptance passes: migrate individual Pools, Disks, ZFS, Snapshots, COMSTAR, Services, System, Alerts and Security Center pages into consistent UI components. Keep Security Configuration Backend postponed until visual signoff while not postponing urgent security responses.
