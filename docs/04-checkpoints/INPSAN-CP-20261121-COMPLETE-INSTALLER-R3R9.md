# INPSan Checkpoint — Complete Installer 3.3.0-r3-r9

- **Checkpoint ID:** INPSAN-CP-20261121-COMPLETE-INSTALLER-R3R9
- **Date:** 2026-11-21
- **Repository:** amirsarlak/INPSan
- **Branch:** main
- **Status:** Ready for clean-host installation test
- **Current operational baseline:** INPSan 3.3.0-r3-r9
- **Target platform:** OmniOS/illumos with the existing napp-it web runtime

## Consolidated installer

- **Package:** `INPSan-Complete-Installer-3.3.0-r3-r9-OmniOS.tar.gz`
- **Library file:** [INPSan complete installer](https://chatgpt.com/library?file_id=libfile_abc1db63cfd88191a75a79a3df29762c&account_id=personal)
- **SHA-256:** `fdc700d23b89f226d35339ca91364780654d0145a395b50c21936611c1f2457a`
- **Size:** 444992 bytes

## Included layers

1. Cumulative Web GUI v3.1.13:
   - login integration
   - INPSan brand assets
   - navigation rules
   - dashboard base assets
   - baseline detection, checksum validation, backup and rollback
2. Operational release 3.3.0-r3-r9:
   - telemetry and monitoring modules
   - hardware topology and H240 bay/serial mapping
   - alert engine and event store
   - native napp-it pool bridge
   - SMF manifests and methods
   - dashboard DataAdapter and current dashboard assets
   - package preflight, dry-run, install, verify, rollback and uninstall

## Installation contract

The unified installer runs in this order:

```
Web GUI preflight -> Web GUI install -> INPSan technical install -> verification
```

It does not install OmniOS or napp-it and does not modify ZFS pools, vdevs, COMSTAR, or storage layout. Existing configuration and persistent monitoring/alert state are preserved according to the embedded installers' backup rules.

## Acceptance evidence

The package archive, wrapper syntax, payload layout, source payload checksums, and archive extraction were validated before publication. Final acceptance remains the user's clean OmniOS installation test using:

```
./bin/inpsan-complete-install --preflight
./bin/inpsan-complete-install --dry-run
./bin/inpsan-complete-install --install
./bin/inpsan-complete-install --verify
```

## Next workstream

After installation acceptance, continue in a new conversation header:

**INPSan Dashboard UI — Login, Shell, Navigation and Responsive Design**

Scope order:

1. Dashboard information architecture and widget priorities
2. Login and global shell consistency
3. Navigation/menu cleanup
4. Organization brand colors and design tokens
5. Responsive behavior across browsers, resolutions and operating systems
6. Reduce explanatory clutter and AI-like boilerplate
7. Dashboard visual refinement without changing telemetry truth or storage semantics

The UI work must preserve the accepted telemetry contract, topology identity mapping, pool-candidate behavior, and read-only storage safety boundaries.
