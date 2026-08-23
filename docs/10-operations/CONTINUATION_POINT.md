# INPSan Continuation Point

Checkpoint time: `2026-08-23 17:12 +03:30`  
Source checkpoint: `INPSAN-CP-OPS-001` / private evidence `CP-20260823-EOC-01`

## Completed operational scope

- Dashboard v3.2.4.6-ui1 accepted;
- H240 physical Bay mapping accepted with `verified_live` quality;
- eight present/healthy front-bay disks and verified empty remaining bays;
- ZFS correlation accepted;
- 10-second Live I/O accepted;
- Bay 6/7 removal, Critical incident creation, reinsertion and automatic resolution accepted;
- Event Store history retained;
- all pools healthy;
- outbound notifications disabled.

## Immediate objective

Perform read-only root-cause analysis and policy validation for the five active non-disk alerts before changing Alert rules or enabling delivery.

## Alert categories in scope

1. `fibre-channel`
2. `fma`
3. `network-policy`
4. `power-redundancy`
5. `power-supply`

Each condition must be classified as:

- `REAL FAULT`
- `EXPECTED STATE`
- `POLICY ISSUE`
- `FALSE POSITIVE`

## Read-only collection

```text
date
inpsan-alertctl summary
inpsan-alertctl list --all
fmadm faulty -a
fmdump -eV (bounded output)
fcinfo hba-port
dladm show-phys
netstat -rn
route -p show
```

Use the installed full path for INPSan control commands. Do not publish raw production output to this public repository.

## Prohibited until RCA completion

- no Alert clear, acknowledge or silence;
- no FMA repair/acquit action;
- no manual chassis-map edit;
- no additional disk removal testing;
- no SMTP, Webhook or Syslog channel enablement;
- no Event/Audit Store cleanup.

## Following sequence

1. Complete active-alert RCA.
2. Correct proven false positives without suppressing real faults.
3. Run targeted regression and native verification.
4. Conduct controlled channel-by-channel Notification delivery tests.
5. Produce operational reports and the next official checkpoint.
6. Continue Stage 1 API, authentication, RBAC, audit, hardening and licensing work.

