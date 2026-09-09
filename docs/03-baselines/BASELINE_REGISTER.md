# INPSan Baseline Register

Register date: `2026-09-09`

## Approved and validated baselines

| Area | Version / state | Status | Validation summary |
|---|---|---:|---|
| Operating system | OmniOS `r151054` | PASS | Established project OS baseline |
| Web GUI | INPSan Complete Web GUI `v3.1.13` | PASS | Approved Golden baseline |
| Monitoring Foundation | `v3.2.0.5` | PASS | SMF service online; native verification passed |
| Telemetry schema | `1.1` | PASS | Runtime telemetry contract validated |
| Telemetry contract | `1.0` | PASS | Dashboard/collector consumption validated |
| Dashboard/DataAdapter | `v3.2.4.6` | PASS | Accepted operational dashboard/data-adapter baseline |
| Dashboard Alert Action / Hardware Aggregate hotfix | `v3.2.4.6-ui2-r1` operational baseline with later P1 action-path hotfixes | PASS for accepted baseline | Alert action UI and aggregate behavior validated at checkpoint |
| Alert Engine aggregate hotfix | `v3.2.3.0-r3-r2` | PASS | Current validated alert-engine aggregate behavior |
| Dashboard history | historical telemetry foundation | PASS | 1h/6h/24h/7d and epoch-based history validated |
| Dashboard visualization | `v3.2.2.8-r2` historical visual baseline | PASS | Approved chassis/visualization baseline |
| Hardware Health & Inventory | `v3.2.0.11-r4` topology baseline | PASS | H240 via `smrt`; 24/24 physical topology verified |
| iLO/Redfish | telemetry extension `3.2.0.12` | PASS | Connected and fresh at validated checkpoint |
| Alert Engine / Event Store schemas | Alert `1.1`, Event `1.0`, Operations `1.8` | PASS | Current validated operational contracts |
| Accessibility & Readability | `v3.2.3.1-r1` | PASS | High-contrast controls, larger typography and focus state validated |
| FC initiator foundation | QLogic `qlc`, 16 Gb link test | PASS for tested mode | Initiator mode online during test |
| iSCSI/STMF foundation | STMF and iSCSI target services | PASS for tested configuration | LU online during test |
| ZFS ARC stabilization | `zfs_arc_max = 17179869184` (16 GiB) | PASS | Persistent `/etc/system.d/inpsan:zfs-arc`; post-reboot `c_max` verified exactly 16 GiB; pools healthy |

## Non-baseline or conditional versions / states

| Area | Version / state | Status | Reason |
|---|---|---:|---|
| P1 alert-action cleanup | r13-derived action path | PENDING CLEANUP | Canonical asset query, audit remote field, stale engine-version field and state-sync latency still require cleanup before formal packaging |
| Notification channels | adapters/roadmap | DISABLED / HOLD | Must remain disabled until channel-specific validation and security review |
| Kernel panic — smrt | FMA `5dc99e1e-95ee-4871-9791-ec40e8744d10` | OPEN RCA | Real Aug 05 panic in `smrt_physical_free`; do not acquit yet |
| Kernel panic — pageout deadman | FMA `5c61c9de-cca3-4b1e-abbf-6b0334af7119` | MITIGATED / OPEN RCA | High memory/ARC occupancy plus savecore workload correlated with `pageout_deadman`; exact lower-layer `VOP_PUTPAGE` stall not yet isolated |
| Crash-dump extraction on production | `savecore` extraction | SUSPENDED | Triggered second kernel panic under high-memory conditions; perform offline/build-matched analysis instead |
| Physical disk-to-bay stability | current implementation | PARTIAL PASS | Stable topology baseline exists; broader removal/reinsert/replacement lifecycle validation remains pending |
| NTP synchronization | current host | PENDING | Timezone set; synchronization acceptance remains pending |

## Baseline interpretation

The latest package number is not automatically the latest approved baseline. Only changes with explicit runtime evidence and PASS status enter this register. The ARC 16 GiB value is an operational stabilization baseline, not yet a final performance-optimized value.
