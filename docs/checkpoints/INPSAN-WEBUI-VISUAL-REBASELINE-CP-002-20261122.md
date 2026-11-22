# INPSAN-WEBUI-VISUAL-REBASELINE-CP-002 — Login v6.1.4 Handoff to Full Web GUI Redesign

**Date:** 2026-11-22 (operator server date, UTC+03:30)  
**Project:** INPSan — OmniOS / napp-it enterprise storage management  
**Repository:** amirsarlak/INPSan  
**Branch:** feature/login-brand-ui-20261121  
**Parent checkpoint:** INPSAN-SECURITY-POSTBOOT-CP-001-20261122  
**Status:** **CHECKPOINT ACCEPTED FOR PHASE HANDOFF**; the complete product UI redesign and Security Configuration Backend are NOT implemented.

## 1. Operator-provided live baseline

The operator supplied on-appliance install output and real Chrome screenshots for **INPSan Login & Security UX v6.1.4**, including:
- Installer `--activate`: ACTIVATE PASS.
- Installer `--verify`: both `admin.pl` CGI trees, `SecurityCenter.pm`, associated assets/CSS matched staged SHA: VERIFY PASS.
- Installer `--status`: `INPSan Login v6.1.4: active`, parent v6.1.3 marker active.
- Screenshot evidence: Login page with explicit “temporarily blocked for up to 5 minutes”; first-login Security Wizard with selectable plans and a review summary; approved logo mark and corrected Persian caption; login/after-login favicon appeared consistent in observed screenshots.
- Earlier live screenshot evidence: Security Center `Authentication audit` shows success/failure and legacy session-removal events; server-verified client IP attribution, Account policy 5 attempts/15 min/5 min lock; successful login Audit and count reset.
- Operator confirmed: logo/persian glyph and responsive defects corrected, transient pre-login Dashboard flash corrected; wizard selectable options and review UI now present.

**Acceptance boundaries:**
- This is a **visual/UI and draft-workflow handoff**. Actual post-logout re-login persistence of wizard draft was not yet independently documented in the shared outputs; verify before claiming complete acceptance.
- Wizard choices are administrative **draft/planning only**: do NOT change live MFA, IP ACL, TLS certificates, session configuration, passwords, or notification delivery.
- Security Center audit UI is read-only. Legacy logout session removal audit is **not** cryptographic/user-verified sign-out.
- Self-signed lab TLS trust, legacy session identifiers in URL, limited password KDF/session hardening, Nginx crash supervision, actual notification provider, and secure transactional settings apply remain open.
- No source binary/package has been installed by this GitHub checkpoint; all evidence about live state is operator-supplied.

## 2. Infrastructure baseline to preserve

- HTTPS Gateway `:8081` online and boot SMF active; TCP `:81` external access blocked by persistent IPv4+IPv6 IP Filter while `127.0.0.1:81` works.
- Actual reboot at 2026-11-22 15:05 (local) confirmed both services back online; post-boot login success, real-IP audit and persistent HTTP81 rule presence confirmed.
- AuthGuard Trusted Edge r2 enforced, failure and lock policy 5 / 15 / 5, audit retention 90 days.
- Storage pools reported healthy; STMF services online and three LU entries existed, but operator reports no attached hosts or serving storage workload. Do not treat this as permission to modify/destroy ZFS/LU configuration.

## 3. Approved design direction

**User decision:** BEFORE implementing live Security Configuration Backend, complete a coherent **Web GUI-wide visual redesign and information architecture**, aligned with the approved Login page's look-and-feel.

Brand palette / design tokens:
- Primary dark navy: `#081B36`
- Primary accent blue: `#0A84FF`
- Cyan: `#00C2D4`
- Green: `#22C55E`
- Approved INPSan logo and Persian subtitle assets are identity anchors; preserve exact shape, spelling, dots, and color. Do not synthesize approximate brand text as an alternative source.

Design and layout scope includes:
1. Main Dashboard hierarchy and KPI/status cards
2. Header, global and contextual navigation, sidebar/tree, menu IA and breadcrumbs
3. All existing napp-it/INPSan admin views: tables, forms, search, status panels, alerts, logs, storage/disks/pools/filesystems/snapshots, COMSTAR & services, jobs, settings, system and Security Center
4. Unified typography, both Persian RTL and English LTR, iconography, spacing, surfaces, shadows, buttons, badges, form validation, empty/loading/error states
5. Navigation width, scroll containment and responsive behavior: large desktop, laptop, tablet and narrow viewport, no overflow/clipping
6. Unify authenticated page favicon, page titles, visual branding, company label, and remove inherited `processing, please wait...` and other legacy chrome where safe
7. Accessibility foundations (keyboard focus, contrast, tables at small widths, aria semantics) and consistent feedback/status hierarchy
8. Preserve menu features, RBAC and operational workflows: no action accidentally disabled by CSS or wrong overlay; old and new pages must not conflict

**Implementation principle:** use a centrally defined, versioned INPSan design system with a CSS namespace and a compatibility layer for legacy napp-it pages. Do NOT globally override arbitrary vendor selectors in a way that breaks custom controls, tables, iframes or the rendering of FC/storage pages.

## 4. Change management & acceptance

- Phase A: audit all legacy screens/components/routes and create UI inventory + visual mapping + approved design token sheet. Then mockups for Dashboard, menus, tables/forms, Security Center and representative storage pages.
- Phase B: implement shared shell/navigation and component classes in small, independently reversible packages; compare baseline screenshots; fix overflow and RTL/LTR.
- Phase C: migrate remaining screen groups with consistent look, functional smoke tests, no regressions in logout/login/auth, storage screens and legacy menus.
- Phase D: operator review and signoff on desktop/laptop/tablet/mobiles; post-signoff create full visual baseline checkpoint.
- **Only after visual UI baseline signoff** begin separate **Security Configuration Backend** with privileged broker, persisted schema, authorization, staged apply, health checks, audit and rollback; while keeping existing security protections operational. Do not defer critical security incident response simply to preserve roadmap ordering.

**Every package:** source-version pin, CGI/auth strict contract, no accidental use of live credentials in logs, `--preflight`, `--dry-run`, `--stage`, `--activate`, `--verify`, `--rollback`, SHA256 and on-host browser acceptance. Preserve both `data` and `data_22.03` CGI trees as needed. Keep independent root SSH for gateway/UI patch.

**Prohibited in visual-only work:** ZFS/pool/LU changes, COMSTAR/STMF/FC changes, Nginx/TLS/SMF/IP Filter/Guard policy changes unless separately justified as a specific, reviewed security fix.

## 5. Next deliverable

`INPSan Web GUI Design System & Dashboard vNext`:
- complete current screen inventory,
- approved dashboard and navigation prototypes,
- shared scoped CSS/design tokens and component specifications,
- rollout matrix per legacy screen group,
- reversible first implementation patch and screenshots.

**This checkpoint does not claim that the redesign has already started on the live appliance.**
