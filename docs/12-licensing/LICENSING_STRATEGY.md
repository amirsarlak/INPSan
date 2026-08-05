# INPSan Licensing and Third-Party Compliance Strategy

Document status: `APPROVED FOR PRODUCTIZATION PLANNING`  
Version: `1.0`  
Date: `2026-08-06`

> This is an engineering and product-governance strategy, not a substitute for review by qualified legal counsel before commercial distribution.

## 1. Upstream licensing position

### OmniOS

OmniOS is an open-source operating-system distribution. Its components are governed by their respective licenses. Production packaging must preserve required notices and source/license obligations for redistributed components.

### OpenZFS

OpenZFS is licensed under the Common Development and Distribution License (CDDL) unless otherwise noted.

Engineering implication:

- maintain a component-level license inventory;
- preserve CDDL notices for covered files;
- keep modified covered source and proprietary INPSan components clearly separated;
- publish or provide covered-source obligations where legally required.

### napp-it

The official napp-it licensing page states that:

- the free SE base version is available to end users, including commercial in-house use;
- redistribution, bundling or setup on behalf of other firms is not permitted under the free end-user model;
- commercial bundling/preconfigured systems require napp-it Pro bundling or a separate agreement;
- Pro extensions are non-free and require entitlements.

## 2. Mandatory Stage 1 productization decision

Before INPSan is sold, preinstalled or deployed for customers, one of these routes must be formally selected.

### Route A — Preferred: INPSan technical independence

- build the INPSan management/control plane directly on documented OmniOS, OpenZFS and COMSTAR/STMF interfaces;
- do not ship napp-it proprietary code, UI assets, extensions, keys or derived files;
- allow optional interoperability with a separately user-installed napp-it environment only where technically and contractually safe;
- treat napp-it as a temporary development/compatibility dependency, not the product runtime foundation.

Advantages:

- independent product roadmap;
- reduced vendor lock and entitlement risk;
- clear INPSan feature ownership;
- easier appliance licensing and support;
- no forced coupling to napp-it Pro expiration.

### Route B — Transitional: commercial napp-it agreement

- obtain a written bundling/distribution agreement covering every shipped system and required extension;
- document which functions are napp-it functions and which are INPSan functions;
- prevent INPSan licensing from representing napp-it features as internally owned;
- define support and update responsibilities contractually.

This route may shorten time-to-market but retains commercial and technical dependency.

## 3. Recommended INPSan commercial model

Recommended top-level editions:

### INPSan Community / Lab

- single node;
- non-critical evaluation, lab or community use;
- core visibility and limited management;
- community documentation;
- no guaranteed response SLA.

### INPSan Enterprise Node

- production single-node appliance;
- full Stage 1 security, API, RBAC, audit, reports and support features;
- annual subscription or perpetual entitlement with annual maintenance;
- offline activation supported.

### INPSan Enterprise Site / Fleet

- Stage 2 centralized multi-node and multi-site capabilities;
- site/fleet entitlement rather than fragile per-MAC-only licensing;
- central manager, automation, replication policy and enterprise integrations.

Final pricing and edition boundaries must be validated against customer value and support cost; they should not be encoded prematurely into the architecture.

## 4. Recommended entitlement architecture

Use a signed, offline-verifiable license document.

Suggested claims:

- license ID;
- customer/organization ID;
- product and edition;
- enabled feature set;
- node count or site scope;
- issue and expiry dates;
- maintenance/security-update eligibility date;
- grace period;
- installation/fingerprint binding where applicable;
- rehost counter or authorization;
- signature algorithm and key ID.

Security design:

- sign licenses using an offline-protected private key;
- embed only the public verification key in INPSan;
- use a modern algorithm such as Ed25519 or an approved ECDSA profile;
- support key rotation through key IDs;
- log verification results without exposing the license payload unnecessarily;
- never place the signing private key on an appliance or public CI runner.

## 5. Non-destructive expiry policy

License expiry must never:

- stop existing storage I/O;
- export or destroy pools;
- offline LUNs or shares;
- block data reads;
- delete configuration, snapshots or evidence;
- trigger unapproved external communication.

Recommended expiry behavior:

1. visible warning before expiry;
2. configurable grace period;
3. existing storage and safety functions continue;
4. security updates remain installable according to the published security policy;
5. premium management/automation features may become read-only or reject creation of new premium jobs after grace;
6. backup/export/recovery functions remain available;
7. reactivation restores entitlements without data-plane restart.

## 6. Hardware binding and rehost

Avoid binding solely to one MAC address because NIC replacement, virtualization and HA can create operational failures.

Preferred fingerprint model:

- stable system UUID plus selected hardware attributes;
- tolerance for expected component replacement;
- explicit rehost workflow;
- emergency temporary license for failed-hardware recovery;
- site/fleet licenses not tightly bound to individual NICs.

## 7. Repository and source-governance model

Before proprietary code is committed, select one of these models:

### Proprietary product

- public repository contains approved documentation, SDKs and genuinely open components;
- proprietary control-plane/appliance source remains in a private repository;
- binaries include third-party notices and open-source obligations.

### Open-core product

- clearly define the open core and its license;
- enterprise extensions remain separately licensed;
- APIs and data formats remain documented;
- avoid source-license ambiguity between modules.

The current public repository does not yet contain a complete product-code license. A `LICENSE`, `THIRD_PARTY_NOTICES`, `SBOM` and component license matrix are mandatory before code distribution.

## 8. Third-party compliance deliverables

Stage 1 must produce:

- `LICENSE` for INPSan-owned material;
- `THIRD_PARTY_NOTICES`;
- software bill of materials;
- component/license matrix;
- source-offer or source-publication process where required;
- napp-it dependency declaration and selected route;
- EULA and support terms;
- privacy/telemetry statement;
- export/security review where applicable;
- release approval checklist signed by product, engineering and legal owners.

## 9. License-related acceptance gate

INPSan Single-Node GA is blocked until:

1. napp-it bundling/redistribution risk is resolved;
2. all shipped components have a recorded license;
3. license expiry behavior is tested and proven non-destructive;
4. offline activation, rehost and failed-hardware recovery are tested;
5. no private signing key exists in product source or build artifacts;
6. customer data remains accessible independent of entitlement state.

## Official references

- OpenZFS license: https://openzfs.github.io/openzfs-docs/License.html
- OmniOS project: https://omnios.org/
- napp-it licensing/extensions: https://www.napp-it.org/extensions/index_en.html
