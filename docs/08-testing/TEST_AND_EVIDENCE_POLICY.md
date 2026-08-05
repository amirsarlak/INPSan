# INPSan Test and Evidence Policy

Version: `1.0`

## Test classes

Every applicable work package must define:

- functional tests;
- negative/failure tests;
- regression tests;
- upgrade tests;
- rollback/recovery tests;
- browser/UI tests;
- performance or soak tests where relevant;
- security tests where authentication, secrets, APIs or outbound integrations are affected.

## Minimum PASS evidence

1. package name and SHA256;
2. host and OS version, sanitized if public;
3. pre-change service/configuration state;
4. installation command and return status;
5. post-change service status;
6. functional output;
7. acceptance-criteria matrix;
8. known limitations;
9. approval date.

## Disk/bay acceptance matrix

The physical-bay feature requires at minimum:

| Test | Expected result |
|---|---|
| Remove occupied disk | Exact bay becomes `MISSING/REMOVED`; no neighboring bay corruption |
| Reinsert same disk | Same identity returns to same bay; stale error clears correctly |
| Insert new disk in empty bay | New disk appears in the correct physical slot |
| Move disk to another bay | Identity remains the disk identity; physical location updates |
| Simulated/real failed disk | Exact bay shows failed/degraded state and relevant alert |
| Reboot/rescan | Mapping remains deterministic |
| Duplicate/conflict condition | UI reports ambiguity rather than inventing a mapping |

## Public evidence handling

Use paths such as:

```text
docs/08-testing/evidence-index/<TEST-ID>.md
```

The index may reference a private evidence location. Do not commit credentials, private IPs, full serial inventories or confidential raw logs to the public repository.
