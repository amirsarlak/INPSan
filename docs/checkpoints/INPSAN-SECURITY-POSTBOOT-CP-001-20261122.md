# INPSAN-SECURITY-POSTBOOT-CP-001 — Live Acceptance Baseline

Date: 2026-11-22 (server local time UTC+03:30)
Repository: amirsarlak/INPSan
Status: **ACCEPTED for management HTTPS + runtime/boot firewall recovery only**. Not a product-wide security certification.
Evidence: operator-supplied OmniOS/Windows console output and screenshots; not an independent remote machine inspection.

## Verified live on INPSan (172.25.25.48)
- OmniOS-backed ZFS: `zpool status -x` => “all pools are healthy”.
- HTTPS gateway Nginx `:8081`, TLS path, `svc:/application/inpsan/https-gateway-boot:default` online and enabled.
- Authentication Guard Trusted Edge r2: admin successful login `AUTH_LOGIN_SUCCEEDED` 2026-11-22T13:19:28Z, `source_ip=172.25.25.6`, `source_method=gateway-attested`, `source_verified=true`, schema v2; recent failed counter reset to zero, lock inactive.
- Login lock policy: 5 invalid attempts / 15 min => 5 min temporary account lock, 90 days audit; lock threshold and actual delivery of notifications NOT accepted.
- Firewall: IPv4 and IPv6 `pass in quick on lo0 ... port=81` plus `block in quick proto tcp ... port=81`, `svc:/application/inpsan/http81-isolation:default` online, IP Filter online.
- Remote Windows TCP check: HTTPS `:8081` true; HTTP `:81` false, observed from client source address `10.0.0.33`.
- Backend loopback `http://127.0.0.1:81/cgi-bin/admin.pl` HTTP 200.
- Reboot verified at 2026-11-22 15:05 (local) using `who -b`; both SMF services and firewall rules observed online/active after reboot.
- STMF and FC-fabric related services online; three logical units listed; one IQN target present. This does NOT prove FC mapping or ESXi connectivity.
- Operator confirms no host attached and no active storage-serving workload. Do not infer there are no imported pools or configured LUs.

## Live packages and operator test state
- Authentication Guard r1: `INPSan-Auth-Protection-5x15-5m-Candidate-r1`
- Authentication Guard Trusted Edge r2: `INPSan-Auth-Protection-Trusted-Edge-r2-20261122` — active, audit attribution confirmed.
- Gateway HTTPS 8081: `INPSan-HTTPS-Gateway-8081-Candidate-v1-r3` — active.
- Gateway SMF boot: `INPSan-HTTPS-Gateway-Boot-SMF-Candidate-r1.1-20261122` — active, post-reboot validated.
- TCP81 runtime isolation: `INPSan-Management-HTTP81-Isolation-Candidate-r1` — active.
- TCP81 persistent SMF: `INPSan-HTTP81-Persistent-SMF-Candidate-r2.2-20261122` — active and post-reboot validated.

## Blockers and requested UX corrections — NOT ACCEPTED
1. Invalid-credential feedback missing/poor on login screen.
2. Login logo and Persian brand subtitle diverge from approved design; Persian letter **پ** glyph/dots are wrong. Must replace with exact approved vector/source rather than approximate.
3. Responsive layout clips/hides brand description and overflows on resized/smaller windows.
4. Browser tab favicon remains old.
5. Security Center authenticated Audit Logs and Login/Logout event visibility not implemented; logout audit incomplete.
6. First-login security wizard and editable security policy screens not implemented.
7. Raw legacy “initialize Web-UI, please wait…” response flashes before branded login.
8. Browser “Not secure”: current certificate is self-signed/not client-trusted; independent trust remediation required.
9. Legacy session ID URL, password KDF, crash supervision, first-boot firewall exposure window, notification provider integration, tested lockout and recovery are not finished.

## Change controls for next phase
- Preserve approved colors #081B36 / #0A84FF / #00C2D4 / #22C55E and INPSan/INP branding; approved artwork is an external identity anchor.
- Before patching live CGI in BOTH `data` and `data_22.03`, inspect exact auth r2 hooks and perform fail-closed source contract checks, backup SHA256, preflight, stage, verify, rollback.
- No change to ZFS, COMSTAR, STMF, FC paths, telemetry, security policy, Nginx/SMF or IP Filter in visual-only patch.
- First deliver targeted Login v6 UX hotfix; keep backend auth semantics unchanged. Security Center/wizard are separate gates.
- GitHub checkpoint is a documented baseline; it is **not** evidence that new Login v6 code has been deployed.
