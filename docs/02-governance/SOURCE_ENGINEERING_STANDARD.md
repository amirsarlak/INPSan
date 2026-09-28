# INPSan Source Engineering Standard

Status: **MANDATORY FOR 3.3+**  
Date: 2026-09-28

## Purpose

Reduce key-person dependency and make proprietary modules maintainable, reviewable, auditable and defensible during technical evaluation.

## Required module header

Each first-party source module should identify, as appropriate:
- module name and version;
- purpose;
- company ownership;
- inputs and outputs;
- external/upstream dependencies;
- persistent state;
- security impact;
- failure behavior;
- related ADR/RCA;
- test references.

Do not place secrets, credentials, private customer data or sensitive infrastructure identifiers in comments.

## Commenting rule

Comments and docstrings explain why a non-obvious decision exists, invariants, operational assumptions, security constraints, interoperability workarounds, algorithmic rationale and expected failure/recovery behavior.
Do not mechanically comment trivial syntax.

## Interface contracts

Public CLI/API/module functions must document parameters, output schema, errors, side effects, authorization requirement and compatibility/version behavior.

## Change requirements

Every material change requires an issue/work-package reference, code review, tests, release note when externally observable, documentation update when contracts change, and rollback/compatibility consideration.

## AI-assisted engineering

AI tools may assist development, review or documentation. Product ownership is established through company requirements, architecture, source control, human technical review, tests, design decisions and evidence. Suggested code is not accepted without verification.

## Definition of done

Source is not complete until another qualified engineer can understand and maintain it, critical behavior is tested, security impact is reviewed, evidence is reproducible and ownership/dependency boundaries are explicit.