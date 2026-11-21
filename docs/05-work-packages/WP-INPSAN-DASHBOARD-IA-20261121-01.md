# INPSan Dashboard — P0 Information Architecture / Source Audit

- **Work package:** WP-INPSAN-DASHBOARD-IA-20261121-01
- **Date:** 2026-11-21 / 1405-08-30
- **Status:** DESIGN + STATIC SOURCE AUDIT; NOT LIVE ACCEPTED
- **Parent:** INPSAN-CP-20261121-COMPLETE-INSTALLER-R3R9
- **Baseline:** INPSan 3.3.0-r3-r9, OmniOS r151054, napp-it runtime
- **Source archive:** INPSan-Complete-Installer-3.3.0-r3-r9-OmniOS.tar.gz
- **Archive SHA-256:** fdc700d23b89f226d35339ca91364780654d0145a395b50c21936611c1f2457a
- **Renderer source:** payload/technical/dashboard/dashboard.pl
- **Renderer SHA-256:** 8996bf845df87e312fd17de34b6b5a9bad3807f3963e2ec8b2ffa7b5ede921bb
- **Primary CSS:** payload/technical/web-assets/data_22.03/wwwroot/_my/inpsan-dashboard-v3.2.1/dashboard.css
- **CSS SHA-256:** 4ce01ed07d8eaa928eaa7cd022254808e50ecffc7e1b27f1d1075f9e16875267

## 1. User-locked work order

1. Dashboard content hierarchy and widget prioritization.
2. Global shell, Login and Header.
3. Menus and Navigation.
4. INP brand colors and design tokens.
5. Responsive browser / viewport behaviour.
6. Remove redundant explanatory and boilerplate copy.
7. Final visual QA without changing Telemetry or Storage Safety.

This work package concerns **step 1 only**. Subsequent stages must preserve its information hierarchy.

## 2. Static source audit findings

- Current renderer has eight executive summary cards: Overall health, Active alerts, Storage health, Monitoring status, Server power, iLO/Redfish, Temperature sensors, Uptime. Dense first viewport.
- Four fixed executive modules coexist with an optional widget workspace, resulting in duplicated health and operation summaries.
- Legacy dashboard header assignment shows 'v 3.2.2', while current renderer is '3.3.0-r3-r9'.
- Header contains an unconditional '30-day trial' license assertion. This is not a verified live license source.
- Runtime banner and numerous widget headings include verbose internal architecture explanations.
- Styles include many 7–10px text declarations and multiple legacy override layers. Actual browser impact must be verified on running host.
- Renderer uses numeric fallbacks that can turn absent or nonnumeric data into 0 in some *display* contexts. This must be audited for measured-vs-unavailable semantics before any visual refactor.
- The dashboard file in the consolidated web-GUI payload is not necessarily the installed operational renderer: the technical installer deploys the v3.3.0 renderer to v3.2.1 paths, and explicitly copies the associated v3.2.1 JS/CSS assets. Do not patch only the legacy webgui/v3.1.13 file.

## 3. IA target — home dashboard

### Tier 0 — Always visible (P0)
1. **System health:** observed/aggregate status, not a synthetic green PASS.
2. **ZFS pool health:** authoritative pool status, count, capacity and exceptions.
3. **Active critical/warning alerts:** counts and a direct drill-down.
4. **Telemetry freshness:** last real sample age, source readiness and stale/unavailable state.

### Tier 1 — Immediately following executive strip (P1)
1. Critical alert / incident queue with age and context.
2. Pool summary and quick access to pool details.
3. Live I/O (10-second sampling; preserve genuine zero vs unavailable).
4. Physical chassis/Bay overview with verified identity map.
5. Hardware health and connectivity condensed, with drill-down.

### Tier 2 — Optional operational widgets (P2)
- CPU, memory and ARC;
- iLO/PSU/Fan/temperature detail;
- FC/iSCSI/Ethernet and service status;
- performance history and capacity trends;
- pool candidates and maintenance/scrub details;
- monitoring foundation details, audit and diagnostic views.

Pool candidates must remain read-only; notifications and alert actions retain their existing controls, availability and acceptance gates.

## 4. Visual / interaction rules

- Prefer 4 equal-width P0 cards at desktop and 2-column / 1-column fallback at narrower viewports.
- Support quick drill-down, persistent headings and clear keyboard focus.
- Separate warnings, observations, predictions, unknown, offline, disabled, stale and unavailable. Unknown must never be silently rendered as OK or 0.
- Keep alert/FMA overlay separate from observed disk/Bay operational health; a historical FMA case does not change an ONLINE disk into failed.
- Display an explicit provenance/freshness state for every dynamic metric.
- Make 24-slot H240 topology visualization and serial/Bay linkage authoritative only when verified_live.
- Never label a feature as enabled/licensed without a real license source.
- Do not surface unsupported storage controls or imply completion of snapshot, replication or report workflows.

## 5. Immutable engineering and safety scope

**May change:** presentation-only HTML, CSS, non-semantic copy, visual grouping and verified read-only drill-down links.

**May not change in this work package:** DataAdapter parsing, collectors, schemas, source timestamps, alert rules/actions, Event Store, audit trail, storage commands, SMF service logic, ZFS, COMSTAR/STMF, drive identity, topology mapping, FMA state, licensing enforcement, secrets or notification-channel state.

Do not run fmadm repaired/acquit/flush, zpool clear/replace/export, devfsadm or HBA reset during UI acceptance. No production stress or crash dump extraction.

## 6. Acceptance gate (to be evidenced, not yet PASS)

- [ ] Actual live DOM confirms all four P0 cards, each with authoritative source state.
- [ ] No absent metric represented as valid zero / healthy state.
- [ ] No unverified license trial claim.
- [ ] Alert counts match Alert Engine current state, with Event Store/audit preserved.
- [ ] Chassis mapping (Controller→Port→Box→Bay→Serial→Device) unchanged and verified.
- [ ] No hidden widget management, alert action or navigation regression.
- [ ] Browser + viewport test: 1920×1080, 1440×900, 1366×768, 1024×768, 768px, 390px.
- [ ] Keyboard and 200% browser zoom: no clipped text, overlapping widgets or inaccessible controls.
- [ ] Baseline r3-r9 package installer/checksum unchanged, or a separately versioned UI-only delta with backup/rollback.
- [ ] Screenshots and browser evidence collected before claiming visual PASS.

## 7. Next implementation gate

Produce a UI-only candidate against the extracted operational dashboard renderer and CSS, with checksum-pinned preflight and reversible change-set, followed by browser evidence on a test install. The 3.3.0-r3-r9 clean-host installation acceptance is independent and remains pending.

## 8. Offline UI-only candidate (not live accepted)

- **Artifact:** `INPSan-Dashboard-UI-P0-IA-Candidate-20261121.tar.gz`
- **SHA-256:** `a8fa64d43656078ecbd681be4148d0f400d4ff627c3b4fe6094b80f2a66c3438`
- **Payload:** checksum-pinned replacement for operational `dashboard.pl` and `dashboard.css` only.
- **Static tests:** Perl syntax PASS, Bash syntax PASS, SHA-256 source verified, archive creation PASS.
- **UI changes:** four P0 executive cards in first row, reduced secondary-card prominence, fixed-module ordering (Alerts, Storage, Runtime, Connectivity), responsive grids, neutral legacy header title, removal of unsupported hardcoded 30-day license claim.
- **Safety:** no JS/DataAdapter/Telemetry/Alert Engine/ZFS/COMSTAR modification, no service restart, and no automatic notification activation; preflight fails if deployed files do not match recognized SHA-256 baselines. Per-file backup and rollback supplied.
- **Acceptance:** PENDING clean-host r3-r9 install, OmniOS patch preflight, browser/visual checks and live data-contract verification.
- **Distribution:** candidate archive is supplied to the user as a conversation artifact; project source payload is not committed to this documentation-only public repository.
