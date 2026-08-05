# INPSan Engineering Documentation

Version: **Framework v1.0**  
Bootstrap date: **2026-08-05**  
Repository role: **Engineering source of truth for approved project documentation**

## Purpose

This documentation records:

1. what was implemented;
2. what problem was addressed;
3. how the problem was resolved;
4. how the result was validated;
5. which version became an approved baseline;
6. what remains pending, blocked or unverified.

## Status model

Only the following status terms are valid:

- `PROPOSED`
- `APPROVED`
- `IN PROGRESS`
- `IMPLEMENTED`
- `AWAITING VALIDATION`
- `PARTIAL PASS`
- `PASS`
- `FAILED`
- `BLOCKED`
- `DEFERRED`
- `DEPRECATED`
- `SUPERSEDED`

A component is not an operational baseline merely because installation or coding completed. `PASS` requires evidence-based validation.

## Navigation

| Area | Document |
|---|---|
| Product | [Product Overview](00-product/PRODUCT_OVERVIEW.md) |
| Roadmap | [Master Roadmap](00-product/MASTER_ROADMAP.md) |
| Architecture | [Architecture Overview](01-architecture/ARCHITECTURE_OVERVIEW.md) |
| Governance | [Documentation Policy](02-governance/DOCUMENTATION_POLICY.md) |
| Baselines | [Baseline Register](03-baselines/BASELINE_REGISTER.md) |
| Current state | [Current Operational State](03-baselines/CURRENT_OPERATIONAL_STATE.md) |
| Historical implementation | [Historical Work Packages](05-work-packages/HISTORICAL_WORK_PACKAGES.md) |
| Architecture decisions | [ADR Register](06-decisions/ADR_REGISTER.md) |
| Problems and root causes | [RCA Register](07-issues-and-rca/RCA_REGISTER.md) |
| Test governance | [Test and Evidence Policy](08-testing/TEST_AND_EVIDENCE_POLICY.md) |
| Releases | [Release History](09-releases/RELEASE_HISTORY.md) |
| Next action | [Continuation Point](10-operations/CONTINUATION_POINT.md) |
| Templates | [`templates/`](templates/) |

## Evidence boundary

This repository is public. It may contain sanitized command excerpts and non-sensitive screenshots, but must not contain secrets, internal IP addressing, credentials, tokens, complete production logs or raw serial-number inventories. Sensitive evidence must be retained in an approved private evidence store and referenced by an evidence ID.
