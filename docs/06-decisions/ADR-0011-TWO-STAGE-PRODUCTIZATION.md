# ADR-0011 — Two-Stage Productization Model

Status: `ACCEPTED`

## Context

The original six-phase roadmap accurately described technical capability growth, but it did not provide a sufficiently clear commercial delivery boundary. INPSan already has a mature storage/monitoring foundation while critical productization work—security hardening, independent control plane, licensing, upgrade/restore and supportability—remains incomplete.

## Decision

Govern the product through two macro stages:

1. **Secure Single-Node Productization and General Availability**;
2. **Enterprise Scale, Automation and Ecosystem**.

The previous six phases remain as implementation workstreams under these two stages.

## Rationale

- preserves all validated work;
- creates a clear GA boundary;
- prevents premature multi-node/AI work from delaying a sellable secure single-node product;
- places hardening and licensing inside the delivery gate;
- aligns roadmap, release, support and commercial planning.

## Consequences

- Stage 1 maturity is lower than the earlier technical-foundation percentage because its scope is broader;
- API/RBAC/audit, licensing, hardening and restore/rollback are now GA blockers;
- Stage 2 begins only after the single-node product is supportable and legally distributable;
- all future checkpoints must report both technical maturity and productization maturity.
