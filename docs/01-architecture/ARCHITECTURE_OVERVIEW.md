# INPSan Architecture Overview

Document status: `APPROVED`  
Last reconstructed: `2026-08-05`

## Layered architecture

```text
Enterprise Management (future)
  API | RBAC | Audit | Reports | Scheduler | Plugins
                    |
Central / Multi-node Control Plane (future)
                    |
Dashboard and Operations UI
                    |
Alert Engine | Event Store | Notification Adapters
                    |
Monitoring | Telemetry | History | Inventory | Health
                    |
OmniOS | OpenZFS | COMSTAR/STMF | Device Drivers
                    |
Server | HBA | Disks | Enclosures | Network | iLO
```

## Current validated layers

### Storage foundation

- OmniOS r151054 is the established operating-system baseline.
- OpenZFS provides pools, datasets, snapshots and storage semantics.
- COMSTAR/STMF provides the block-storage service foundation.
- FC and iSCSI paths have been tested in the project environment.

### Monitoring and telemetry

The native Monitoring Foundation collects and exposes:

- CPU topology and utilization;
- memory and ARC metrics;
- per-interface network counters and calculated utilization;
- storage/pool data;
- SMART and hardware inventory where available;
- historical time-series data consumed by the dashboard.

### Hardware discovery and management

- HPE H240 is recognized through the OmniOS `smrt` driver.
- PCI/HBA inventory is available.
- iLO 5/Redfish integration is online in the validated environment.
- chassis views support the approved 24-bay front and 12-bay rear visual layouts.

### Alerting

- Event Store and Alert Engine are operational.
- Alert presentation in Dashboard Alerting & Operations is validated.
- Notification channels are intentionally not enabled until channel-specific acceptance testing is completed.

## Identity model

Transient device paths are insufficient for physical-bay management. The intended identity chain is:

```text
Persistent disk identity (WWN/serial where available)
        +
Controller/enclosure relationship
        +
Physical enclosure and slot
        =
Stable logical-to-physical reconciliation
```

The architecture decision is approved; full operational validation across removal, reinsertion and new-disk discovery remains pending.

## Future control plane

The next architecture layer must provide:

- versioned REST API;
- RBAC and scoped authorization;
- immutable/auditable operation records;
- asynchronous jobs;
- report scheduling;
- multi-node registration and health aggregation;
- secure plugin and integration boundaries.
