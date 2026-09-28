# INPSan Control Plane v0.1.0-dev

Development-only, read-only prototype.

## Security boundary

- binds to `127.0.0.1` only;
- supports `GET` only;
- has no state-changing endpoint;
- is **not** production-ready authentication/security;
- must not be exposed to a management network in this development state.

## Implemented endpoints

- `GET /api/v1/product/version`
- `GET /api/v1/system/health`
- `GET /api/v1/storage/pools`

Contract-defined but not implemented yet:
- `/api/v1/storage/disks`
- `/api/v1/hardware/topology`
- `/api/v1/performance/live`
- `/api/v1/alerts`
- `/api/v1/events`

## Start

`/usr/bin/perl inpsan-control-plane-v0.1.0-dev.pl --port 18080`

Then query loopback only:

`curl -s http://127.0.0.1:18080/api/v1/product/version`

`curl -s http://127.0.0.1:18080/api/v1/system/health`

`curl -s http://127.0.0.1:18080/api/v1/storage/pools`

## Verify

`./verify.sh`

Live OmniOS validation is required before this prototype can be marked PASS.