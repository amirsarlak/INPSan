# INPSan UX Provenance & Experience-Driven Operations Requirements v1.0

Status: **ACTIVE PRODUCT REQUIREMENT**  
Date: 2026-09-28

## 1. Product-ownership objective

INPSan UI/UX must be visibly and demonstrably the result of company-owned human product engineering, not a generic template or undifferentiated AI-generated dashboard.

Evidence of ownership shall come from:
- documented operator personas;
- company-authored workflows;
- design rationale;
- component-level design system;
- usability review notes;
- version history;
- ADR/product requirements;
- source and tests.

The project shall not rely on visual claims alone to demonstrate ownership.

## 2. Experience-driven design doctrine

Operational views must be derived from the R&D team's long-term field experience with enterprise storage, SAN/NAS, network/security infrastructure and organizational IT operations.

Each widget, alarm and report must answer a concrete operational question.

Examples:
- Is a pool becoming capacity-risky before it reaches an unsafe threshold?
- Is latency a workload issue, path issue, media issue or memory/ARC pressure?
- Which physical drive maps to the logical fault and what is the safe operator action?
- Is an FC path loss expected maintenance, redundancy loss or service risk?
- Is a workload behaving abnormally compared with its own historical baseline?
- Is a snapshot/recovery policy being weakened?
- Are privileged changes occurring outside normal operating patterns?
- Is an organization approaching a capacity, performance or resilience threshold?

## 3. Required persona set

At minimum:
- Storage Administrator;
- Infrastructure/Virtualization Engineer;
- Network/SAN Engineer;
- NOC Operator;
- SOC/Security Operator;
- IT Manager;
- Auditor/Compliance Reviewer;
- Support/Field Engineer.

Every major view must identify its primary and secondary persona.

## 4. Alarm design contract

An alarm is not accepted merely because a metric crossed a threshold.

Each alarm definition must include:
- alarm ID and version;
- operational/security problem;
- source signals;
- trigger logic;
- suppression/debounce logic;
- severity rationale;
- affected asset;
- confidence/quality indicator where derived;
- operator context;
- recommended verification/action;
- false-positive/false-negative notes;
- maintenance-mode behavior;
- escalation path;
- test/evidence reference.

## 5. Report design contract

Each report must identify:
- business/operational question;
- audience;
- data sources;
- time range;
- freshness;
- exclusions/limitations;
- risk/health interpretation;
- drill-down path;
- export/audit requirements.

## 6. Customization model

Customization is per-user and per-organization but remains subordinate to security policy.

User-customizable:
- layout;
- widgets;
- saved filters;
- time ranges;
- preferred drilldowns;
- saved views;
- selected report presets.

Organization-customizable:
- thresholds within approved bounds;
- site-specific dashboards;
- report templates;
- schedules;
- escalation policy;
- maintenance windows;
- alert routing;
- role-specific presets.

Policy-locked:
- mandatory security alerts;
- audit settings;
- critical availability controls;
- evaluator-required security settings;
- organization security baseline.

All security-relevant customization is auditable.

## 7. Visual design constraints

Prefer:
- high information density without clutter;
- consistent hierarchy;
- stable spatial location for operational elements;
- restrained component vocabulary;
- meaningful charts rather than decorative graphics;
- accessible contrast and readable typography;
- direct mapping between alarm, asset and action;
- consistent empty/loading/stale/degraded/error states.

Avoid:
- generic card-wall dashboards;
- excessive gradients/glow/decorative AI aesthetics;
- repeated same-shape widgets without semantic reason;
- oversized empty spacing that reduces operator context;
- ambiguous icons;
- charts with no decision value;
- arbitrary visual novelty.

## 8. Design provenance evidence

For major UX releases retain:
- source requirement;
- persona/workflow;
- wireframe or design decision;
- rationale;
- usability/field review;
- before/after comparison;
- implemented component/source commit;
- regression/accessibility test;
- screenshot evidence.

## 9. Knowledge-based evidence

The UX/operations layer is part of the proprietary productization value.

Evidence should demonstrate:
- transformation of domain expertise into software behavior;
- non-trivial alert/report logic;
- data-model integration;
- physical/logical correlation;
- operational decision support;
- organization-specific configurability;
- security/audit integration;
- iterative engineering history.

## 10. Acceptance rule

No major monitoring/alarm/reporting screen is complete unless both:
1. the implementation works technically; and
2. its operational rationale and evidence of company-owned design are documented.
