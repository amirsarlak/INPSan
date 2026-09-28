# INPSan Control Plane API Contract v0.1

Status: **READ-ONLY DEVELOPMENT CONTRACT**  
Date: 2026-09-28  
Parent: CP-KB-001 / WP-3.3-001 / Issue #8

## 1. Goal

Provide a stable, versioned interface over existing validated INPSan telemetry/operations data without changing the storage data path or coupling clients to implementation files.

Base prefix:

`/api/v1`

## 2. Common response envelope

```json
{
  "ok": true,
  "schema_version": "1.0",
  "generated_at": "RFC3339 timestamp",
  "data": {},
  "meta": {
    "source_version": "string",
    "freshness": "fresh|stale|unknown|source_unavailable"
  }
}
```

Error envelope:

```json
{
  "ok": false,
  "schema_version": "1.0",
  "error": {
    "code": "stable_error_code",
    "message": "operator-safe message"
  }
}
```

## 3. Read-only endpoints v0.1

| Endpoint | Permission | Purpose |
|---|---|---|
| `GET /api/v1/system/health` | `system.read` | Product/system summary |
| `GET /api/v1/storage/pools` | `storage.read` | Pool inventory/health/capacity |
| `GET /api/v1/storage/disks` | `storage.read` | Logical disk inventory |
| `GET /api/v1/hardware/topology` | `topology.read` | Chassis/bay/HBA/hardware mapping |
| `GET /api/v1/performance/live` | `performance.read` | Current I/O/performance snapshot |
| `GET /api/v1/alerts` | `alerts.read` | Current alert records |
| `GET /api/v1/events` | `events.read` | Event timeline |
| `GET /api/v1/product/version` | `system.read` | Component/build versions |

## 4. Query semantics

List endpoints may support:
- `limit` with bounded maximum;
- `cursor` for pagination;
- `severity` where relevant;
- `status` where relevant;
- `category` where relevant;
- `entity` canonical identifier;
- `since` / `until` RFC3339 timestamps for event/history-oriented resources.

Unknown query parameters return a validation error rather than being silently ignored.

## 5. Freshness semantics

Every telemetry-derived response exposes freshness based on the producer timestamp and source policy.

`healthy` and `fresh` are independent concepts. Stale data must never be converted to a healthy conclusion.

## 6. Identifier rules

- use persistent/canonical identifiers where available;
- transient OS device paths are attributes, not primary identity;
- physical slot + serial/WWN correlation is preserved;
- API consumers must not parse display strings for identity.

## 7. Prototype implementation boundary

v0.1 development starts with adapters over existing validated state/read models. It does not modify ZFS, COMSTAR/STMF, SMF state, alert controls or configuration.

## 8. Future state-changing endpoints

Not part of v0.1. They require completed AuthN/RBAC/Audit/TLS implementation gate and separate ADR/API review.

## 9. Compatibility

- endpoint path is versioned;
- response schema carries its own version;
- additive fields are preferred;
- incompatible changes require a new contract version;
- DataAdapter/telemetry internals may evolve without breaking the external API contract.

## 10. Initial acceptance test

Prototype PASS requires:
- valid JSON;
- stable envelope;
- read-only behavior;
- source-unavailable handling;
- stale/fresh distinction;
- no secret exposure;
- loopback-only default until security stack is implemented.