# WP-3.3-001 — INPSan 3.3 Engineering Foundation

Status: **STARTED**  
Start date: 2026-09-28  
Parent checkpoint: **INPSAN-CP-KB-001**

## Objective

Create the engineering contracts required to evolve the validated INPSan 3.2.x platform into the 3.3 knowledge-based product line without destabilizing the accepted storage/monitoring baseline.

## Scope

### A. Architecture and ownership
- freeze 3.2.x operational baseline;
- define module boundaries and ownership;
- classify upstream, integrated and proprietary components;
- establish versioned interface/data contracts.

### B. Source engineering standard
Every proprietary module must provide purpose, owner, inputs/outputs, dependencies, security impact, failure modes, public interface contract, rationale comments and test references.

### C. Evidence integration
Each work item must produce implementation artifact, test artifact, evidence index entry, release lineage and applicable complexity/performance metrics.

### D. Benchmark foundation
Establish a read-only framework for CPU/memory, ARC context, telemetry storage overhead, collector duration/freshness, alert latency, DataAdapter/dashboard response and startup/recovery timing.

### E. UX foundation
Document Storage Admin, NOC/SOC, Infrastructure Engineer, IT Manager and Auditor personas, critical workflows, interaction design tokens and dashboard customization policy.

### F. Security architecture
Before Control Plane implementation define trust zones, authentication, RBAC, session model, audit, secrets/certificates, secure API transport, signed update/integrity model and a TOE boundary draft.

## Deliverables
- Knowledge-Based Product Architecture v1;
- Knowledge-Based Readiness Matrix;
- Source Engineering Standard;
- Benchmark Specification/Harness;
- Security Architecture v1;
- UX Design System foundation;
- module ownership/evidence register;
- Control Plane implementation backlog.

## Non-goals
- no rewrite of OpenZFS/COMSTAR/OmniOS;
- no Predictive AI claim before implementation;
- no Central Manager before secure API contracts;
- no modification of accepted storage data paths;
- no implicit enablement of outbound notification channels.

## Acceptance criteria
PASS only when current proprietary modules are inventoried, 3.3 modules have contracts, source standard is adopted, benchmarks are reproducible, security architecture is reviewed, UX workflows are reviewed and the first coding package can proceed without architectural ambiguity.

## Current progress
- Master Roadmap rebaselined: PASS.
- CP-KB-001: PASS.
- Knowledge-Based Architecture v1: CREATED.
- Readiness Matrix: CREATED.
- Work package: STARTED.
- Security Architecture v1: CREATED on development branch.
- IODS v1 foundation: CREATED on development branch.
- Benchmark Collector v0.1.0-dev: CREATED on development branch; live validation pending.
- GitHub implementation backlog: issues #4–#9 OPEN.
- Benchmark Collector live validation: PASS.
- 3.2.x resource baseline: RECORDED.
- Source/Module Census: PASS — 43 normalized current code files / 7,419 LOC; evidence indexed.
- IODS Implementation Contract v1: PASS — Issue #6 completed.
- Control Plane Security Contract v1: PASS — Issue #7 completed.
- Control Plane API Contract v0.1: CREATED.
- Read-only Control Plane prototype v0.1.0-dev: IMPLEMENTED on development branch; live OmniOS validation pending.
- AuthN/RBAC/Audit coding task: Issue #10 OPEN, gated behind read-only live validation.
- Next gate: live-validate Control Plane v0.1.0-dev, then implement remaining read-only adapters.