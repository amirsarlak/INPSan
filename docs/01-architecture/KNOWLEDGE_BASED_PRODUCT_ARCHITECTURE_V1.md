# INPSan Knowledge-Based Product Architecture v1.0

Status: **ACTIVE ARCHITECTURE BASELINE**  
Date: 2026-09-28

## 1. Architectural objective

INPSan is an enterprise storage productization and operational-intelligence layer built on a proven storage foundation. The architecture intentionally separates upstream storage capabilities from company-developed modules and future R&D.

## 2. Big picture

Enterprise Experience: Personas / Custom Workspace / Reports / Alerts / Audit / Operations
↓
Independent Control Plane [R&D]: REST API / AuthN / RBAC / Audit / Jobs / Config / Secrets / Reports
↓
Operations Intelligence: Event Store / Alert Engine / Policy / Startup Readiness
+ Local Predictive Intelligence [R&D]: Features / Baselines / Anomaly / Forecast / Explainability / Drift
↓
INPSan Observability & Data Model: Telemetry / History / DataAdapter / Live I/O / Health / Topology
↓
Hardware Intelligence: SMART / HBA / FMA / Redfish / Physical Bay Reconciliation
+ Storage/Protocol Integration: Pool / Dataset / LUN / FC / iSCSI correlation
↓
UPSTREAM FOUNDATION: OmniOS / illumos / OpenZFS / COMSTAR-STMF / OS drivers
↓
Hardware: Server / HBA / Disks / Enclosures / NIC / BMC-iLO

Central Manager [Stage 2 R&D] manages fleet health/config/update/reporting through the secure Control Plane and remains outside the storage data path.

## 3. Ownership classification

| Layer / module | Ownership | Current status | Knowledge-based claim |
|---|---|---|---|
| OmniOS / illumos | Upstream | Operational | No |
| OpenZFS semantics | Upstream | Operational | No |
| COMSTAR/STMF | Upstream | Operational | No |
| Monitoring Foundation | INPSan | Implemented | Yes |
| Telemetry/history contracts | INPSan | Implemented | Yes |
| Dashboard DataAdapter | INPSan | Implemented | Yes |
| Hardware Health/Inventory | INPSan | Implemented | Yes |
| Physical Bay Reconciliation | INPSan | Implemented/validated lineage | Yes |
| iLO/Redfish Provider | INPSan integration | Implemented | Yes, integration/normalization only |
| Live I/O Telemetry | INPSan | Implemented | Yes |
| Event Store / Alert Engine | INPSan | Implemented | Yes |
| Startup Readiness / stability policy | INPSan | Implemented | Yes |
| Customizable Operations Workspace | INPSan | Planned 3.3 | Not yet |
| Independent Control Plane | INPSan | Planned 3.3 | Not yet |
| Predictive Intelligence | INPSan | Planned R&D | Not yet |
| Central Manager | INPSan | Planned R&D | Not yet |

## 4. Product-specific operational model

Every product view must answer one or more explicit operator questions:
- What is unhealthy now?
- What changed?
- Which logical object maps to which physical component?
- Is performance abnormal relative to this system's baseline?
- What is the probable operational impact?
- What evidence supports the alert?
- What action is safe and appropriate?
- What is the trend/forecast?
- What changed in configuration/security state?
- Can the system continue operating safely?

## 5. Security boundaries

Management plane, storage data plane and telemetry/analytics plane are distinct trust zones.
The Control Plane must not become a dependency for block/file data service availability.
The Central Manager must not enter the data path.
Predictive analysis processes operational telemetry and metadata by default; customer payload content is out of scope unless explicitly designed, approved and protected in a future release.

## 6. Evidence model

Each proprietary module must maintain source owner, dependencies, version/build, architecture contract, measurable complexity, tests/evidence, security impact, performance envelope, ADR/RCA lineage and demo scenario.

## 7. Compatibility principle

Existing validated 3.2.x modules remain usable during 3.3 development. New 3.3 components integrate through versioned contracts so modernization does not require a disruptive rewrite of the storage foundation.