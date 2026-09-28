# INPSan Live Security Validation Procedure — v0.2.2-dev

Status: READY FOR EXECUTION
Checkpoint context: CP-SEC-003
Target: OmniOS INPSan development/evaluation node

## Purpose

Collect runtime evidence for:
- S1 AuthN;
- S2 RBAC/Object Scope;
- S3 Security Audit.

The validation is non-destructive and read-only with respect to storage.

## Preconditions

- use the 3.3 engineering branch files;
- run locally on the INPSan OmniOS node;
- keep the Control Plane loopback-only;
- do not expose port 18082 externally;
- do not run during unrelated destructive hardware testing;
- existing 3.2.x storage services remain untouched.

## Execute

From `src/control-plane`:

```sh
bash live-validate-security-v0.2.2.sh
```

The script:
1. runs static security verification;
2. runs role/scope matrix verification;
3. discovers the first two pools read-only;
4. creates isolated test identities under `/var/tmp`;
5. starts the dev Control Plane on `127.0.0.1:18082`;
6. tests anonymous denial;
7. tests invalid credentials;
8. tests named-user login;
9. tests role-level access;
10. tests exact pool scope;
11. tests cross-pool denial where a second pool exists;
12. tests logout/replay rejection;
13. verifies audit file permissions;
14. checks password leakage;
15. verifies audit hash-chain integrity;
16. confirms loopback-only binding;
17. generates an evidence hash manifest.

## Expected role behavior

| User | Role | Pool list | Scoped Pool 1 | Pool 2 without grant |
|---|---|---:|---:|---:|
| sec_viewer | viewer | 200 | 200 | 403 |
| sec_storage | storage-admin | 200 | 200 | 403 |
| sec_security | security-admin | 403 | 403 | 403 |
| sec_auditor | auditor | 200 | 200 | 403 |
| sec_platform | platform-admin | 200 | 200 | 403 |

All users must:
- authenticate successfully with the test credential;
- receive 200 from `/auth/me`;
- logout successfully;
- receive 401 when replaying the revoked token.

Anonymous protected access must return 401.

Invalid password must return 401.

## Evidence location

The script creates:

`/var/tmp/inpsan-sec-live-YYYYMMDD-HHMMSS/`

Return these files for review:
- `summary.txt`
- `static-security.txt`
- `static-role-scope.txt`
- `user-provisioning.txt`
- `audit-verify.txt`
- `security-audit.jsonl`
- `server.log`
- `SHA256SUMS.txt`

Do not send any file that contains a live bearer token or real production password.

## PASS criteria

S1/S2/S3 may advance only if:
- mandatory status codes match the expected matrix;
- user store and audit files are restrictive;
- no test password appears in audit;
- audit chain verifies;
- service remains loopback-only;
- static tests pass;
- no production data path is modified.

A successful run does not close TLS, MFA, audit retention/export, secrets lifecycle or write-operation security gates.
