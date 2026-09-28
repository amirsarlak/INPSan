# INPSan Knowledge-Based Readiness Matrix

Date: 2026-09-28

Status legend: **PASS** = implemented/demonstrable/evidence-backed; **PARTIAL** = implemented but incomplete evidence/security/productization; **PLANNED** = future R&D and not currently claimable.

| Module / capability | Ownership | Complexity | Demo | Evidence | Security | KB readiness | Action |
|---|---|---:|---|---|---|---|---|
| Storage foundation (ZFS/COMSTAR) | Upstream | High upstream | Yes | Yes | Baseline | Not proprietary | State boundary clearly |
| Monitoring Foundation | INPSan | High | Yes | Yes | PARTIAL | Strong | benchmark + code census |
| Telemetry/History contract | INPSan | High | Yes | Yes | PARTIAL | Strong | document schema/freshness semantics |
| DataAdapter/Operations model | INPSan | High | Yes | Yes | PARTIAL | Strong | formal API/data contract |
| Hardware Health/Inventory | INPSan | High | Yes | Yes | PARTIAL | Strong | complexity metrics + test matrix |
| Physical Bay mapping | INPSan | High | Yes | Yes | Good | Strong | preserve failure/recovery evidence |
| iLO/Redfish integration | INPSan integration | Med/High | Yes | Yes | PARTIAL | Strong | secure credential/cert lifecycle evidence |
| Live I/O telemetry | INPSan | Med/High | Yes | Yes | PARTIAL | Strong | overhead benchmark |
| Event Store | INPSan | High | Yes | Yes | PARTIAL | Strong | immutability/retention tests |
| Alert Engine | INPSan | High | Yes | Yes | PARTIAL | Strong | false-positive/latency metrics |
| Startup Readiness/Stability | INPSan | High | Yes | Yes | Good | Strong | retain reboot evidence |
| Notification Engine | INPSan | Medium | Partial | Yes | PARTIAL | Medium | controlled channel acceptance |
| Current Dashboard | INPSan | Medium | Yes | Yes | PARTIAL | Medium | supersede presentation with IODS |
| Product-specific UX Design System | INPSan | Med/High | No | No | N/A | PLANNED | WP-3.3-002 |
| User-customizable workspace | INPSan | High | No | No | Policy-sensitive | PLANNED | contract then implementation |
| Independent Control Plane | INPSan | High | No | No | Critical | PLANNED | WP-3.3-005 |
| Auth/RBAC/Audit | INPSan | High | No | No | Critical | PLANNED | before Central Manager |
| Local Predictive Intelligence | INPSan | High | No | Historical data exists | Critical data/privacy | PLANNED | WP-3.3-006 |
| Central Manager | INPSan | High | No | No | Critical | PLANNED | after API/security contract |
| Security certification evidence | INPSan process | High | Partial | Partial | Critical | PARTIAL | TOE/ST/control matrix |
| CI / automated test / CD | INPSan process | Med/High | Partial | Partial | Important | PARTIAL | engineering foundation |
| Performance benchmark framework | INPSan | High value | No | No | N/A | PLANNED | WP-3.3-004 |
| SBOM / supply-chain governance | INPSan process | Medium | Partial | Partial | Critical | PARTIAL | automate inventory |

## Priority gaps

### P0 — close before broad feature expansion
1. Product/module ownership and source census.
2. Source documentation and code-review standard.
3. Benchmark harness and current 3.2.x resource baseline.
4. Security architecture, TOE boundary and secure-management requirements.
5. INPSan Operations Design System and operator personas.

### P1 — next implementation
1. Versioned Control Plane API foundation.
2. Authentication/session/RBAC/audit.
3. Customizable workspace model with administrator policy locks.
4. Report template/scheduling foundation.

### P2 — intelligence and fleet scale
1. Predictive data-quality gates and feature store.
2. Deterministic baselines and anomaly detection.
3. Central Manager node-enrollment and fleet telemetry.
4. Model registry/explainability/drift monitoring.

## Claim rule

A feature becomes claimable only after implementation, source ownership, passing tests, a passing demo scenario, indexed evidence, recorded complexity metrics, security-impact review and release/baseline approval.