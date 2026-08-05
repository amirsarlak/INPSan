# INPSan Baseline Register

Register date: `2026-08-05 23:22 +03:30`

## Approved and validated baselines

| Area | Version / state | Status | Validation summary |
|---|---|---:|---|
| Operating system | OmniOS `r151054` | PASS | Established project OS baseline |
| Web GUI | INPSan Complete Web GUI `v3.1.13` | PASS | Approved Golden baseline |
| Monitoring Foundation | `v3.2.0.5` | PASS | SMF service online; native verification passed |
| Telemetry schema | `1.1` | PASS | Runtime telemetry contract validated |
| Telemetry contract | `1.0` | PASS | Dashboard/collector consumption validated |
| Dashboard history | `v3.2.1.6` historical baseline | PASS | 1h/6h/24h/7d and epoch-based time axis validated |
| Dashboard visualization | `v3.2.2.8-r2` | PASS | Approved chassis/visualization baseline |
| Hardware Health & Inventory | `v3.2.0.11-r2` | PASS | H240 via `smrt`, SAS/HBA, fans and temperatures recognized |
| iLO/Redfish | `v3.2.0.12-r1` | PASS | iLO 5 integration online in validated environment |
| Alert Engine & Event Store | `v3.2.3.0` | PASS | Installed and operational |
| Dashboard Alerting & Operations | `v3.2.3.1` | PASS with later UI correction | Alert display validated |
| Accessibility & Readability | `v3.2.3.1-r1` | PASS | High-contrast menus/selects, larger typography and focus state validated |
| FC initiator foundation | QLogic `qlc`, 16 Gb link test | PASS for tested mode | Initiator mode online during test |
| iSCSI/STMF foundation | STMF and iSCSI target services | PASS for tested configuration | LU online during test |

## Non-baseline or conditional versions

| Area | Version / state | Status | Reason |
|---|---|---:|---|
| Dashboard IA candidate | `v3.2.2.9` | PARTIAL PASS | Functional progress accepted; severe UI contrast/readability defects remained |
| Dashboard Corrective Stabilization | `v3.2.4.3` | AWAITING VALIDATION | Package SHA and `[9/9] Preflight successful` confirmed; installation and browser acceptance not yet confirmed |
| Notification channels | adapters/roadmap | BLOCKED BY ACCEPTANCE | Must remain disabled until channel-specific validation and security review |
| Physical disk-to-bay reconciliation | current implementation | PARTIAL PASS | Architecture selected; complete remove/reinsert/add-disk validation pending |
| NTP synchronization | current host | PENDING | Timezone set; synchronization not yet accepted as healthy |

## Baseline interpretation

The latest package number is not automatically the latest approved baseline. Where a newer package is awaiting validation, the preceding validated component remains the operational reference.
