# INPSan Product Overview

Document status: `APPROVED`  
Last reconstructed: `2026-08-05`

## Product definition

INPSan is evolving from a customized storage-management console into an **Enterprise Storage Platform** built on:

- OmniOS;
- OpenZFS;
- COMSTAR/STMF;
- native telemetry and monitoring;
- hardware inventory and health monitoring;
- dashboard visualization;
- alert/event processing;
- a future API, RBAC, reporting, automation and centralized multi-node control plane.

## Current validated product position

The validated foundation includes:

- stable Web GUI baseline;
- Monitoring Foundation and historical telemetry;
- dashboard visualization and time-range support;
- CPU, memory/ARC, network and storage telemetry;
- SMART, HBA, PCI and hardware-health inventory;
- HPE iLO/Redfish integration;
- front/rear chassis visualization;
- Alert Engine and Event Store;
- alert presentation in the operations dashboard;
- accessibility and readability corrections;
- tested FC and iSCSI service foundations.

## Strategic destination

The target product is a unified platform with:

- scalable multi-node management;
- centralized multi-site visibility;
- API-first operations;
- enterprise RBAC and audit;
- report generation and scheduling;
- policy-driven automation and orchestration;
- predictive analytics and capacity planning;
- integration with virtualization, backup and hybrid-cloud ecosystems.

## Engineering principles

1. **Evidence before baseline** — a package is not `PASS` until validated.
2. **Persistent identity** — storage objects must not depend only on transient device paths.
3. **Open architecture** — platform features should remain independently maintainable.
4. **Separation of concerns** — telemetry, event storage, alert processing and UI presentation are separate layers.
5. **Safe operations** — upgrade, rollback and negative testing are mandatory for production changes.
6. **No hidden activation** — notification channels remain disabled until explicitly tested and approved.

## Product boundary

INPSan currently uses OmniOS/OpenZFS/COMSTAR as the storage foundation. The project adds management, telemetry, visualization, health, alerting and future enterprise-control capabilities. It must not claim that every roadmap capability is already implemented.
