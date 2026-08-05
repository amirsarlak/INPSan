# ADR-0012 — License Safety, Third-Party Compliance and napp-it Independence

Status: `ACCEPTED FOR STAGE 1`

## Context

INPSan is intended to become a commercial storage product. OmniOS/OpenZFS provide an open-source foundation, while napp-it has separate free, Pro, extension and bundling conditions. A product license must never endanger access to customer data.

## Decision

1. Prefer an independent INPSan management/control plane built on documented OmniOS, OpenZFS and COMSTAR/STMF interfaces.
2. Do not redistribute napp-it proprietary code, extensions, UI assets or keys without a written commercial bundling agreement.
3. Create a complete SBOM, third-party notice set and component-license matrix before GA.
4. Implement signed offline-verifiable entitlements.
5. License expiry must be non-destructive and must not stop existing storage I/O or recovery operations.
6. Avoid fragile MAC-only binding; support stable fingerprinting, rehost and failed-hardware recovery.

## Alternatives considered

- continue indefinitely with napp-it Free as a product dependency;
- ship a preconfigured napp-it-based appliance without a bundling agreement;
- use strict entitlement enforcement that disables the appliance on expiry;
- bind every license permanently to one MAC address.

These alternatives were rejected because of redistribution, supportability, resilience and customer-data risks.

## Consequences

- independent control-plane implementation becomes part of Stage 1;
- a transitional napp-it commercial agreement remains possible but must be explicit;
- license architecture requires a protected signing process and rehost workflow;
- product source/repository licensing must be selected before code distribution;
- legal review remains required before commercial launch.
