# INPSan Architecture Decision Register

| ADR | Decision | Status | Summary |
|---|---|---:|---|
| ADR-0001 | OmniOS and OpenZFS foundation | ACCEPTED | Use OmniOS/OpenZFS as the storage and operating foundation |
| ADR-0002 | COMSTAR/STMF block-storage foundation | ACCEPTED | Use native COMSTAR/STMF for FC/iSCSI service capabilities |
| ADR-0003 | Native telemetry service architecture | ACCEPTED | Run monitoring as a persistent SMF-managed native service |
| ADR-0004 | Persistent disk identity plus physical slot | ACCEPTED / VALIDATION PENDING | Do not rely only on transient device paths for bay mapping |
| ADR-0005 | Separate Event Store and Alert Engine | ACCEPTED | Keep persistence, evaluation and presentation as separate concerns |
| ADR-0006 | Evidence-based baseline policy | ACCEPTED | `IMPLEMENTED` does not become `PASS` without validation evidence |
| ADR-0007 | REST API and RBAC control plane | PROPOSED | Next enterprise-control layer |
| ADR-0008 | Central manager and federated nodes | PROPOSED | Primary scalability direction |
| ADR-0009 | GitHub documentation source of truth | ACCEPTED | Approved engineering documentation is version-controlled here |
| ADR-0010 | Notification channels disabled by default | ACCEPTED | No channel activation before security and delivery acceptance tests |
| ADR-0011 | Two-stage productization model | ACCEPTED | Stage 1 delivers secure single-node GA; Stage 2 delivers scale, automation and ecosystem |
| ADR-0012 | License safety and napp-it independence | ACCEPTED FOR STAGE 1 | Resolve redistribution risk and make license expiry non-destructive |

Detailed high-impact decisions are documented in adjacent ADR files.
