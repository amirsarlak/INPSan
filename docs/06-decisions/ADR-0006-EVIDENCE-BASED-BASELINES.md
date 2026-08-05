# ADR-0006 — Evidence-based Operational Baselines

Status: `ACCEPTED`

## Context

A package may install successfully while still containing functional, visual, operational or regression defects. Version number alone cannot determine production readiness.

## Decision

Use explicit lifecycle states and permit `PASS` only after acceptance criteria and evidence are satisfied.

## Required evidence

- package identity and hash;
- pre-change state;
- installation result;
- service/runtime status;
- functional test;
- negative test where applicable;
- regression test;
- rollback plan or verified recovery route;
- final acceptance record.

## Consequence

Dashboard Corrective Stabilization v3.2.4.3 remains `AWAITING VALIDATION` even though its hash and preflight passed.
