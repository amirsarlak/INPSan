# INPSan Baseline Register

Register date: `2026-08-23 17:12 +03:30`

## Approved and validated baselines

| Area | Version / state | Status | Validation summary |
|---|---|---:|---|
| Operating system | OmniOS `r151054` | PASS | Established production OS baseline |
| napp-it host UI | `22.03` | PASS | Current operational host integration |
| Web GUI | INPSan Complete Web GUI `v3.1.13` | PASS | Approved Golden baseline |
| Monitoring Foundation | `v3.2.0.5` | PASS | SMF service online; native verification passed |
| Telemetry schema / contract | `1.1` / `1.0` | PASS | Runtime collection and Dashboard consumption validated |
| Dashboard | `v3.2.4.6-ui1` | PASS | Readability, responsive compact disk view, numeric Bay order and capacity labels accepted |
| Dashboard DataAdapter | `3.2.4.6` | PASS | Operations schema `1.8`; physical Bay, ZFS and Live I/O correlation accepted |
| Hardware topology | `v3.2.0.11-r3` | PASS | H240 physical Bay mapping reports `verified_live` |
| Bay 7 identity map | `v3.2.0.11-r3-map1` | PASS | Expected identity and remove/reinsert lifecycle accepted |
| Hardware Health & Inventory | `v3.2.0.11-r2` | PASS | H240 via `smrt`, SAS/HBA, fans and temperatures recognized |
| iLO/Redfish | `v3.2.0.12-r1` | PASS | iLO 5 integration online in validated environment |
| Live I/O | `v3.2.0.13` | PASS | Dedicated read-only 10-second disk I/O samples accepted |
| Alert Engine & Event Store | `v3.2.3.0-r1` | PASS | Current adapter loaded; physical-Bay opened/resolved lifecycle accepted |
| Alert state / Event schema | `1.1` / `1.0` | PASS | Durable lifecycle records validated |
| Notification Engine | `v3.2.4.0-r1` | PASS / DISABLED | Native verification passed; all outbound channels disabled |
| Notification Center | `v3.2.4.1` | PASS / DISABLED | Dashboard control plane accepted; no outbound delivery enabled |
| FC initiator foundation | QLogic `qlc`, 16 Gb link test | PASS for tested mode | Initiator mode online during test |
| iSCSI/STMF foundation | STMF and iSCSI target services | PASS for tested configuration | LU online during test |

## Current validated operational state

- all ZFS pools healthy at the final checkpoint;
- 24-Bay front chassis: eight disks present and healthy, remaining bays verified empty;
- physical mapping quality: `verified_live`;
- Bay 6 and Bay 7 removal/reinsert lifecycle: `PASS`;
- Event Store recorded independent `opened` and `resolved` incidents;
- outbound notifications remain disabled.

## Conditional or pending items

| Area | Status | Reason |
|---|---:|---|
| Five non-disk active alerts | PENDING RCA | Power, FMA, Fibre Channel and network-policy categories require read-only classification |
| Notification delivery | DISABLED / AWAITING ACCEPTANCE | Channel-specific security, queue, retry and delivery tests are pending |
| NTP upstream quality | PENDING REVIEW | Historical unstable-peer events are retained; current source policy still requires operational review |
| Stage 1 API/RBAC/audit/licensing | PROPOSED / NOT YET IMPLEMENTED | Productization work remains outside this operational checkpoint |

## Baseline interpretation

The latest package number is not automatically the latest approved baseline. `PASS` requires native verification, regression evidence and, where applicable, live operational acceptance.

