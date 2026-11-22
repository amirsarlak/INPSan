# INPSan Web GUI Design System & Dashboard P0 — Candidate (2026-11-22)

Parent: `INPSAN-WEBUI-VISUAL-REBASELINE-CP-002` at commit `973cebc706064d11279599005475ea7306b15973`.

## Scope and method
Inspected local extracted `INPSan-Complete-Installer-3.3.0-r3-r9` source: Dashboard read-only Perl renderer, dashboard CSS/JS and brand CSS/navigation JS, as well as Login v6.1.4 payload. This is a source-derived **first visual release**, not a claim of exhaustive live-menu coverage.

- Shared shell styles: header, menu palette, breadcrumb, page surfaces, legacy forms/tables, focus.
- Dashboard-only styles: executive hero, statuses and pool cards, network/service/disks, alerts, jobs and quick links.
- Approved transparent INPSan login logo reused unchanged for header background asset.
- No CGI/Perl/collector/JavaScript menu, Authentication Guard, Security Center, Nginx, IP Filter, SMF, ZFS, STMF, FC or storage changes.
- Applies scoped CSS overlays with explicit marker to both `data` and `data_22.03` vendor stylesheet trees. New logo asset added in both trees.
- Installer guards both-tree consistency and the known `v3.1.13` source contract, stages backed-up original SHA256 manifests, activates only when live source matches, verifies and can roll back original CSS byte-identically.

## Archive
`INPSan-WebGUI-DesignSystem-Dashboard-P0-Candidate-20261122-OmniOS.tar.gz`
SHA256 `2c7fc52da92cf46a922b9771b1ac54c7da70f367ebac103b8bf2df2e3439372f`
Format USTAR. Candidate files: `README.fa.md`, installer, CSS overlays, approved logo raster, source-backed UI inventory and design token documentation, QA report, HTML demo and sample screenshots.

## Offline verification
- Bash syntax passed, staged source SHA checks passed.
- Full fixture `--preflight`, `--dry-run`, `--stage`, `--activate`, `--verify`, `--rollback`: PASS.
- Source drift at activation rejected; repeat activate after rollback rejected.
- Perl dashboard renderer syntax PASS. Preview rendered using data fixture shipped in development package, explicitly NOT live node values.
- Chromium screenshots produced at 1920x1080, 1366x900, 1024x768, 768x920, 390x844 and 320x740.
- Known shortfall: legacy horizontal menu overflows at 768px in preview; true responsive navigation, submenu accessibility and comprehensive screen-by-screen restyling remain follow-ups.

## Production stage gate
The appliance has NOT yet run this new P0 package. Upload package, verify SHA, execute `--probe`, `--preflight`, `--dry-run`, `--stage`, `--status` only. If source mismatch occurs, do NOT bypass contract; inspect actual CSS. Live activation needs separate approved SSH/rollback window and visual/functional smoke tests across Dashboard, About, Pools, Disks, ZFS, Snapshots, COMSTAR, Services, System, Security Center and Login.

**Important data-fidelity concern:** existing dashboard LU count parser recognizes `Logical Unit:`, while real `stmfadm list-lu` can report `LU Name:`. Existing dashboard can also present “Healthy” if some collectors fail. P0 is CSS-only and does not claim to correct data collector logic. This is a separate tracked acceptance issue.
