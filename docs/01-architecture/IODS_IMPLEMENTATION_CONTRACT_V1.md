# INPSan Operations Design System — Implementation Contract v1.0

Status: **IMPLEMENTATION-READY**  
Date: 2026-09-28  
Parent: CP-KB-001 / WP-3.3-001 / Issue #6

## 1. Design objective

IODS converts the 15-year enterprise storage/infrastructure operational experience of the R&D team into explicit product workflows. The UI is not a generic dashboard template; every high-value element must answer a documented operator question and expose the evidence needed for a safe decision.

## 2. Personas and primary questions

| Persona | Primary operational questions |
|---|---|
| Storage Administrator | Is storage healthy? What changed? Where is the physical component? Is performance abnormal? What action is safe? |
| Infrastructure Engineer | Is server/HBA/NIC/power/thermal hardware healthy and redundant? |
| NOC/SOC Operator | What is critical now, what is the impact, what evidence exists, and what must be escalated? |
| IT Manager | What are capacity, availability, risk and forecast trends? |
| Auditor | Who changed what, when, with what result and what evidence exists? |

## 3. Semantic state model

The UI must never mix these states:

- **Observed Fault** — directly observed current failure/degradation.
- **Warning** — observed condition requiring attention but not a confirmed fault.
- **Anomaly** — statistical deviation from a learned/deterministic baseline.
- **Forecast** — predicted future condition with horizon and confidence.
- **Recommendation** — suggested action, never represented as an observed fact.
- **Informational** — context with no immediate action required.

Each state has a distinct label, iconography and textual semantics. Color alone is insufficient.

## 4. Information hierarchy

Every operational screen follows:

1. current health/impact;
2. affected entity;
3. evidence and timeline;
4. topology/dependency context;
5. trend/history;
6. recommended or permitted action;
7. audit/security context where applicable.

## 5. Widget contract

Every widget must declare:

- `widget_id` and schema version;
- supported persona(s);
- source API endpoint(s);
- refresh/freshness policy;
- required permissions;
- severity semantics;
- configurable inputs;
- policy-lockable properties;
- empty/loading/error/degraded states;
- export capability where applicable.

### Required first-wave widgets

- System Health Summary;
- Active Alerts / Incident Queue;
- Pool Health & Capacity;
- Physical Chassis / Disk Identity;
- Live I/O & Latency;
- FC/iSCSI/HBA Health;
- Hardware Health / Power / Thermal;
- Event Timeline;
- Security & Audit Summary;
- Capacity Trend / Forecast placeholder (disabled until predictive engine acceptance).

## 6. Workspace customization

Per-user persisted settings:
- widget selection;
- layout/order/size;
- time range;
- entity scope;
- filters;
- table columns/sort;
- saved view name;
- default landing view.

Organization-admin policy may lock:
- critical availability/security widgets;
- severity visibility;
- mandatory audit/compliance elements;
- maximum refresh interval for critical views;
- data-retention/report policies.

User customization must never suppress mandatory critical alerts or weaken security policy.

## 7. View presets

Initial presets:
- `storage-admin`;
- `noc-soc`;
- `infrastructure`;
- `it-manager`;
- `auditor`.

Presets are templates only; permissions remain enforced by RBAC.

## 8. Interaction rules

- no destructive action from a summary card;
- state-changing operations require a dedicated action flow;
- every high-risk operation shows target, impact and authorization context;
- stale telemetry is visibly marked;
- unknown/unverified state is never rendered as healthy;
- physical/logical disk identity is displayed together where relevant;
- alert acknowledgement/silence is auditable and permission-gated;
- recommendations are non-executing unless explicitly approved through a future policy/action workflow.

## 9. Design tokens

Define tokens rather than ad-hoc per-screen values:

- spacing scale: 4 / 8 / 12 / 16 / 24 / 32;
- type scale: compact operational text, body, section, title;
- density modes: `compact` and `standard`; default operational tables use compact;
- radius and border rules kept restrained;
- chart grid/axis/legend rules consistent across metrics;
- semantic tokens: healthy / info / warning / critical / unknown / stale / forecast;
- focus/keyboard states mandatory.

Exact visual colors are implementation tokens and may evolve; semantic meaning is stable.

## 10. Data freshness

Every live widget must surface one of:
- `fresh`;
- `stale`;
- `unknown`;
- `source_unavailable`.

Freshness is derived from the source data contract, not browser arrival time.

## 11. Design provenance record

Each major screen must have an evidence record containing:
- persona;
- operator problem;
- source data;
- information hierarchy rationale;
- security constraints;
- acceptance scenario;
- screenshots/version;
- usability findings and resulting changes.

## 12. Acceptance scenarios

IODS v1 is accepted for implementation when a prototype can demonstrate:

1. Storage Admin identifies a degraded entity and reaches physical evidence without ambiguous navigation.
2. NOC/SOC sees critical incidents without hiding mandatory alerts through customization.
3. IT Manager sees capacity/risk trend without access to unauthorized low-level actions.
4. Auditor can navigate from audit summary to actor/action/outcome evidence.
5. stale/unknown states are visually distinguishable from healthy.

## 13. Non-goals

- no claim of predictive intelligence until its engine is implemented and validated;
- no broad re-skin of 3.2.x without workflow mapping;
- no dependency on Central Manager for local operation.