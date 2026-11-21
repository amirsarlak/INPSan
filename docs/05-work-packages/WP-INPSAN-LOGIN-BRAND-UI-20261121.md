# INPSan Login Brand UI — Candidate 01

**Workstream:** Login and Shell visual harmonization (P0.1)  
**Date:** 2026-11-21 / 1405-08-30  
**Status:** OFFLINE CANDIDATE — NOT YET LIVE ACCEPTED  
**Parent:** INPSAN-CP-20261121-COMPLETE-INSTALLER-R3R9  
**Installation baseline:** 3.3.0-r3-r9; Web GUI login assets under `inpsan-login-v3.2`

## Findings from source and screenshot
- Existing login uses a navy-blue full page, a small layered storage SVG logo, a large left presentation block, and a right authentication card.
- The live screenshot shows `v3.2.2` at top-right, while the archived complete installer contains a Web GUI `v3.1.13` render marker. This is an unresolved presentation mismatch; neither value proves which operating components are installed.
- The login template is rendered by `data[/_22.03]/wwwroot/cgi-bin/admin.pl`. Authentication and session behavior must remain intact.
- Presentation assets are `data[/_22.03]/wwwroot/_my/inpsan-login-v3.2/login.css` and `logo.svg`.

## Candidate implementation
- New logo maintains the established layered-storage icon and INPSan name, with refined geometry and a more legible wordmark/tagline.
- Login-only palette: navy `#081B36`, blue `#0A84FF`, cyan `#00C2D4`, status green `#22C55E`.
- Improved card contrast, typography, focus, spacing and responsive sizing.
- Existing version label is hidden through login-scoped CSS until live source can be verified. No runtime version value is rewritten.
- The security/credential messages remain visible. No third-party scripts or fonts are introduced.
- No CGI/auth/session controls, network services, monitoring, alerts, storage, ZFS, COMSTAR or notifications are modified.
- Two CSS files and two SVG files in `data` and `data_22.03` are the only on-host files changed.
- The patch appends a namespaced CSS overlay, preserves originals with SHA-256 backups, and implements preflight/dry-run/install/verify/rollback; no service restart.

## Offline artifact
- `INPSan-Login-Brand-UI-Candidate-20261121-OmniOS.tar.gz`
- SHA-256: `e8f4ac78b0b07b4c8973e65182a7acf0009a6abe808c624f9b6d2667e6239a99`
- CSS SHA-256: `e906cb8af710b753946fff4c0c3eac348f345040753077f96431e5a54f448a6f`
- Logo SVG SHA-256: `59286cfc9227d733d7eedcc4e5641c3f6a4c2804656f1f8a869177b623c38098`

## Evidence
- Local Bash syntax and XML parsing PASS; CSS parsing showed no syntax errors.
- Offline fixture install/verify/rollback PASS, with byte-for-byte restoration of the four original source files.
- Chromium static preview: 1600×900, 1366×768, 1024×768, 768px, 390px and 320px; no horizontal overflow in observed rendered preview. These are design previews, not live OmniOS/CGI acceptance.
- Pending: OmniOS preflight, browser hard refresh, live login success/failure, keyboard/zoom, network and TLS acceptance.
- Existing HTTP management login shown in screenshot requires a dedicated TLS/security workstream; branding overlay does not provide encryption.

## Safe execution sequence
1. Transfer candidate archive to test node and extract.
2. Run `./bin/inpsan-login-ui --preflight` and `--dry-run`.
3. Only if checks pass, run `--install` and `--verify`.
4. Hard refresh login and inspect visual appearance plus existing login flow.
5. If needed, `./bin/inpsan-login-ui --rollback`.

**Do not declare live UI acceptance before host evidence.**
