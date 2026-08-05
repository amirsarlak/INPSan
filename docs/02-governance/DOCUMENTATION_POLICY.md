# INPSan Documentation and Change-Control Policy

Policy version: `1.0`  
Effective date: `2026-08-05`

## Source of truth

The `INPSan` GitHub repository is the source of truth for approved engineering documentation. Chat conversations, temporary scripts, generated packages and local notes are working materials until their validated conclusions are committed here.

## Mandatory traceability chain

```text
Requirement
  -> Work Package / Issue
  -> ADR where architecture is affected
  -> Implementation and package
  -> Test Report and Evidence
  -> Release Notes
  -> Baseline Register
  -> Official Checkpoint
```

## Update rule

For every future INPSan change, documentation is updated in the same engineering cycle:

1. define scope and acceptance criteria;
2. record pre-change state;
3. record problem, impact and root cause;
4. document selected solution and rejected alternatives;
5. record changed files/services/packages;
6. execute functional, negative and regression tests;
7. retain sanitized evidence or reference a private evidence ID;
8. assign an explicit status;
9. update release and baseline registers;
10. issue a checkpoint when a stable boundary is reached.

## Baseline rule

`IMPLEMENTED` is not equivalent to `PASS`.

A release may become an operational baseline only after:

- functional validation;
- regression validation;
- service/runtime verification;
- upgrade and rollback consideration;
- package/hash recording;
- evidence retention;
- explicit acceptance.

## Public-repository safety

Do not commit:

- credentials, passwords or tokens;
- internal IP addresses unless deliberately sanitized;
- raw private logs;
- customer names or confidential topology;
- complete device serial-number lists;
- license files;
- private keys or certificates.

Use placeholders and private evidence references instead.
