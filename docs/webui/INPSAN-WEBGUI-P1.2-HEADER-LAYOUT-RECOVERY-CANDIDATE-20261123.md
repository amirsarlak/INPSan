# INPSan WebGUI P1.2 — Header & Layout Recovery Candidate

Date: 2026-11-23
Parent baseline: `INPSAN-WEBUI-VISUAL-REBASELINE-CP-002`
Previous live operator evidence: P1.1 visually regressed Header/logo (hidden) and Pools/table content (clipped). P1.1 not accepted.

## Release
`INPSan-WebGUI-Header-Layout-Recovery-P1.2-Candidate-20261123-OmniOS.tar.gz`
SHA256: `38e8384f8e9cb89cdd55ef3421b7674a7d7d2dfe295e619b8f5456156c52cdce`
USTAR gzip, installer `bin/inpsan-webui-p12`.

## Mandatory clean baseline
1. Live operator manually executes P1.1 `--rollback` and checks `rolled_back`.
2. P1 `--verify` and `--status` must pass.
3. P1.2 installer fails closed unless P1.1 state is `rolled_back`, P1 is `active`, and all four CSS/menu files match exact P1 proposed manifest and P1.1 original manifest. Do not override gates.

## Root-cause correction
P1.1 used pre-JS `:has(#menupos #menu)` selectors to force `#header`, `#nilogo`, `#content`, breadcrumbs and other elements to changed sizes/positions, conflicting with vendor CSS and P1. P1.2 removes all pre-JS geometry overrides beyond native menu `#menupos/#menu` itself. The approved header/logo and content geometry remain under P1. After JS enhancement only surfaces, tables, breadcrumb colors, focus states are changed.

## Change scope
Four paired files: `brand.css` x2 and `about_menus.txt` x2. Versioned CSS cache key `20261123p12`. Unchanged: `navigation.js`, all CGI, authenticated Security Center, Nginx/IP Filter/SMF, all ZFS/COMSTAR/STMF/FC functionality.

## Offline evidence (not live)
Reconstructed real archived baseline -> P0 -> P1 -> P1.1 -> P1.2 refusal -> P1.1 rollback -> P1.2 preflight/dry-run/stage/activate/verify/rollback: PASS, original P1 SHA returned byte-identical. CSS/browser tests synthetic: Dashboard and Disks 5 viewport widths each (10), delayed-JS logo/menu tests 3 widths (3), 30-column table inner scroll at 5 widths (5) PASS. Untrusted local source modifications rejected on rollback.

## Limitations
Header-height may still change at enhancement (116px legacy -> 72px P1); exact zero-FOUC is NOT claimed. Live DOM/load sequence, dynamic menus, tablet and vendor wide table acceptance remain pending. P1.2 must only be staged on appliance before separately reviewing activation.

## Next gate
After operator stage outputs, limited visual live test of Dashboard, Pools and ZFS at 1920/1366/1024/768/390 and screenshot. Do not migrate to P2 until P1.2 accepted.
