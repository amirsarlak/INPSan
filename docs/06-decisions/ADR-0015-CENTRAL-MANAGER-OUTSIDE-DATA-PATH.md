# ADR-0015 — Central Manager Remains Outside the Storage Data Path

Status: **ACCEPTED AS STAGE 2 ARCHITECTURE**  
Date: 2026-09-28

## Decision

INPSan Central Manager provides fleet visibility, policy, configuration, lifecycle and reporting through authenticated management contracts, but it is not a dependency for FC/iSCSI/NAS data service.

## Consequences

- loss of Central Manager connectivity must not stop storage service;
- nodes retain safe local management capability;
- remote operations require authenticated node identity, RBAC and audit;
- fleet update/configuration requires staged execution and failure containment;
- node enrollment uses a secure management channel;
- Central Manager consumes versioned Control Plane APIs rather than private implementation files.