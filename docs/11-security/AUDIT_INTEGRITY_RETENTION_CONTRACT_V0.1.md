# INPSan Security Audit Integrity & Retention Contract v0.1

Status: **IMPLEMENTATION CONTRACT**  
Date: 2026-09-28  
Parent: CP-SEC-002 / S3 Security Audit Plane

## 1. Objective

Evolve the development JSONL audit writer into a product-grade security audit subsystem suitable for:
- operational security;
- incident investigation;
- AFTA-oriented evaluation evidence;
- Common Criteria FAU-family traceability;
- passive-defense readiness;
- knowledge-based product evidence.

## 2. Canonical audit record

Minimum fields:

- schema_version;
- event_id;
- timestamp;
- actor_id;
- actor_type;
- source;
- session_id or correlation_id where applicable;
- action;
- target_type;
- target_id;
- permission;
- outcome;
- reason;
- client_context where safe;
- product_version;
- node_id;
- sequence_number;
- previous_event_hash;
- event_hash.

No secret/authenticator material is permitted.

## 3. Integrity model

Target design:
1. serialize each event deterministically using canonical JSON;
2. calculate event hash over:
   - canonical event payload excluding event_hash;
   - previous_event_hash;
3. store previous_event_hash and event_hash in each record;
4. maintain monotonically increasing sequence number per node/audit stream;
5. verify chain at startup and during explicit audit verification;
6. raise security event if chain continuity is broken.

The hash chain provides tamper evidence; it is not by itself equivalent to a remote immutable log.

## 4. Stronger evidence / external anchoring

Enterprise/evaluation profile shall support one or more:
- remote authenticated syslog/SIEM export;
- periodic signed audit checkpoints;
- hash-anchor export to a separately protected location;
- WORM/immutable external evidence target.

Exact mechanism remains subject to product/evaluation profile.

## 5. Audit storage and rotation

Requirements:
- restrictive ownership/permissions;
- configurable max active file size;
- rotation by size/time;
- retention by policy;
- no silent deletion of security evidence;
- rotation event itself is audited;
- retained files have manifest/hash;
- archive/export follows authorization policy.

## 6. Capacity health

Audit subsystem shall expose health states:

- OK;
- WARNING;
- CRITICAL;
- WRITE_FAILURE;
- INTEGRITY_FAILURE.

Thresholds must be configurable within policy limits.

At minimum:
- warning before configured audit storage capacity is exhausted;
- critical alert before inability to record mandatory events;
- product health/reporting surfaces audit-capacity condition.

## 7. Failure behavior

If mandatory security audit cannot be written:
- the failure is surfaced immediately;
- protected management operations follow a defined fail-safe policy;
- the product must not silently continue as if evidence were complete;
- storage data-path continuity must not be broken merely because the management audit path is degraded.

For destructive/high-impact management operations, policy may block execution if mandatory audit cannot be persisted. This decision must be explicit per operation class.

## 8. Retention classes

Initial proposal:

### Security Critical
Authentication, authorization denial, identity/RBAC, certificates/secrets, update/rollback, destructive storage/security actions.

### Administrative
Configuration changes, alert acknowledge/silence, report/policy changes.

### Operational
Read-only management access and routine informational events where enabled.

Retention policy may differ by class but must remain auditable.

## 9. Query/export

Authorized users shall be able to:
- filter by time, actor, action, target, outcome, severity/class;
- correlate related events;
- export sanitized audit packages;
- verify chain/hash integrity;
- identify gaps/rotation boundaries.

Permission:
- `audit.read` for read/search;
- separate future permission for audit export/policy management.

## 10. Privacy/minimization

Audit must capture enough context for accountability without collecting customer payload content.

Do not record:
- plaintext passwords;
- bearer tokens;
- CHAP secrets;
- private keys;
- full customer data payload;
- unnecessary sensitive request bodies.

## 11. Performance budget

Measure:
- average event write latency;
- p95/p99 write latency;
- CPU cost;
- file growth/event;
- chain-verification cost;
- rotation cost;
- behavior under burst/security-event storm.

Audit overhead must not materially interfere with storage I/O.

## 12. Test IDs

- SEC-AUD-001 schema completeness
- SEC-AUD-002 actor attribution
- SEC-AUD-003 secret leakage negative test
- SEC-AUD-004 chain continuity
- SEC-AUD-005 tamper detection
- SEC-AUD-006 rotation continuity
- SEC-AUD-007 retention enforcement
- SEC-AUD-008 capacity warning
- SEC-AUD-009 write failure behavior
- SEC-AUD-010 query/filter authorization
- SEC-AUD-011 export authorization
- SEC-AUD-012 performance benchmark
- SEC-AUD-013 restart/recovery chain verification

## 13. PASS rule

S3 cannot become PASS until:
- complete required event coverage exists;
- chain/integrity behavior passes;
- retention/rotation/capacity tests pass;
- authorization around query/export is tested;
- performance evidence exists;
- live OmniOS evidence is retained.
