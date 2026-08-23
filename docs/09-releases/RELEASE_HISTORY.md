# INPSan Reconstructed Release History

This register contains validated or explicitly conditional versions known from the project record.

| Version | Component | Status | Key result |
|---|---|---:|---|
| v3.1.13 | Complete Web GUI | PASS | Golden Web GUI baseline |
| v3.2.0.5 | Monitoring Foundation | PASS | Native SMF monitoring baseline |
| v3.2.0.11-r2 | Hardware Health & Inventory | PASS | H240 `smrt`, SAS/HBA, fans, temperatures |
| v3.2.0.12-r1 | iLO/Redfish | PASS | iLO 5 integration online |
| v3.2.1.6 | Dashboard History | PASS | Historical ranges and epoch axis validated |
| v3.2.2.8-r2 | Dashboard Visualization | PASS | Chassis/visual foundation |
| v3.2.3.0 | Alert Engine & Event Store | SUPERSEDED | Operational core; superseded by r1 lifecycle correction |
| v3.2.3.0-r1 | Alert Engine & Event Store | PASS | Current-adapter reload and physical-Bay lifecycle accepted |
| v3.2.3.1-r1 | Accessibility & Readability | SUPERSEDED | Contrast and typography foundation |
| v3.2.4.0-r1 | Notification Engine | PASS / DISABLED | Verified; all outbound channels disabled |
| v3.2.4.1 | Notification Center | PASS / DISABLED | Control plane accepted; delivery disabled |
| v3.2.4.3 | Dashboard Corrective Stabilization | SUPERSEDED | Intermediate mapping assumption rejected by later live evidence |
| v3.2.4.4-r2 | Physical Bay Truth | PASS | Missing/removed health state and H240 physical truth |
| v3.2.4.5 | ZFS Topology and Responsive Layout | PASS | Live pool/VDEV correlation |
| v3.2.4.6 | Live I/O and Compact Operations | PASS | Read-only 10-second I/O and compact disk operations |
| v3.2.4.6-ui1 | Bay Order and Capacity Hotfix | PASS | Numeric Bay order and visible capacity labels |
| v3.2.0.11-r3-map1 | Bay 7 Expected Identity | PASS | Exact expected identity and live remove/reinsert acceptance |
| v3.2.0.13 | Live I/O service | PASS | Fresh 10-second disk I/O source |

## Accepted package hashes

The private evidence checkpoint retains the complete package/hash table. Publicly recorded final package hashes include:

| Package | SHA256 |
|---|---|
| Dashboard v3.2.4.6-ui1 | `c125434199c034b1593a413c1853d3f7328a307f5a6b95ea0bdf7fcc5dada55a` |
| H240 Bay 7 map1 | `75e3bf4344de388304b086f4b127fb077c6749e32f06d6fbe50a4a267016e5b5` |
| Alert Engine v3.2.3.0-r1 | `2d0a6e9de4bd7dfd30dc36e6bb3dd78d26fa1e3a266172b5a48e10a8d16f8ca6` |

## Release governance

Future release entries must include package hash, source commit/PR, upgrade path, rollback path, test report ID and baseline decision. Binary release archives are not committed to this public documentation repository.

