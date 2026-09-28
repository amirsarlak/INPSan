# INPSan Source/Module Census Baseline — 2026-09-28

**Census tool:** 0.1.0-dev  
**Capture:** 2026-09-28 14:20 +03:30  
**Status:** PASS — initial source/module inventory; file-level language classification

## 1. Capture integrity

- 114 files were inventoried.
- Census contains file metadata, counts and hashes, not source content.
- Capture completed successfully.

## 2. Raw census

| Classification | Files | Lines | Bytes |
|---|---:|---:|---:|
| Perl | 27 | 17,246 | 883,072 |
| Shell | 21 | 270 | 11,181 |
| JSON/Data | 6 | 118 | 3,382 |
| XML | 2 | 66 | 3,024 |
| Markdown | 2 | 14 | 828 |
| Other | 56 | 780 | 159,978 |
| **Total** | **114** | **18,494** | **1,061,465** |

Raw counts must **not** be used directly as proprietary source-code percentages because the census contains historical dashboard copies, backup copies, test fixtures, VERSION/BUILD metadata and two full `admin.pl` integration-host files.

## 3. Normalization rules for current first-party code

For a defensible current-code estimate, the following are excluded from source-language percentages:
- VERSION/BUILD metadata;
- Markdown documentation;
- JSON/XML data/configuration contracts;
- monitor test fixtures;
- historical dashboard versions 3.1.11/3.1.12/3.1.13;
- `dashboard.pl.pre-*` backup copies;
- full napp-it `admin.pl` integration-host files.

The two captured `admin.pl` paths have the same SHA-256 and the same 4,648-line size; the whole upstream/integration host must therefore not be attributed to INPSan proprietary LOC.

The normalized current-code set includes:
- code under `/opt/inpsan` classified as programming source;
- the current `inpsan-dashboard-v3.2.1/dashboard.pl` integration module;
- no historical/backup duplicate.

## 4. Normalized file-level programming composition

| Primary file language | Files | LOC | LOC share |
|---|---:|---:|---:|
| Perl | 22 | 7,149 | **96.36%** |
| Shell | 21 | 270 | **3.64%** |
| **Total** | **43** | **7,419** | **100%** |

These percentages are **file-level primary-language LOC**, not semantic language segmentation. Perl dashboard files may embed HTML/JavaScript/CSS fragments; this census intentionally did not export or parse source contents, so no separate JavaScript/CSS LOC claim is made from this run.

## 5. Normalized current module LOC

| Module | Code LOC | Share |
|---|---:|---:|
| Alert Engine | 1,560 | 21.03% |
| Dashboard DataAdapter | 1,452 | 19.57% |
| Monitoring Foundation | 1,198 | 16.15% |
| Hardware Topology Telemetry | 1,062 | 14.31% |
| Notification Engine | 775 | 10.45% |
| Web-GUI current integration | 321 | 4.33% |
| Notification Center | 316 | 4.26% |
| Live I/O Telemetry | 167 | 2.25% |
| SMART Telemetry | 141 | 1.90% |
| Pool/ARC Telemetry | 119 | 1.60% |
| System Runtime Telemetry | 114 | 1.54% |
| Hardware Health Telemetry | 103 | 1.39% |
| iLO/Redfish Provider | 91 | 1.23% |
| **Total** | **7,419** | **100%** |

## 6. Interpretation

The deployed first-party product layer is currently backend/operations-heavy. The largest identifiable engineering bodies are Alert Engine, Dashboard DataAdapter, Monitoring Foundation and Hardware Topology Telemetry.

This is favorable for the knowledge-based dossier because the measurable codebase is concentrated in telemetry normalization, hardware/storage correlation, event/alert processing and operational productization rather than merely visual theming.

## 7. Important limitations

1. LOC is an evidence metric, not a direct measure of innovation or technical complexity.
2. Legal/source ownership still requires repository/package provenance review; this census proves deployment presence and hashes, not copyright ownership by itself.
3. Embedded HTML/JavaScript/CSS inside Perl files is not separated in v0.1.0.
4. Historical versions remain useful as development-lineage evidence but are excluded from current-code percentages.
5. `admin.pl` is treated as an integration host, not as 9,296 lines of INPSan proprietary code.

## 8. Knowledge-based evidence conclusion

Initial Source/Module Census: **PASS**.

Current defensible file-level source statement:

> The current identifiable INPSan product layer contains at least 7,419 lines of current programming source across 43 deployed code files in the normalized census. At file-primary-language level, 96.36% is Perl and 3.64% is Shell. Front-end technologies embedded inside server-side Perl are documented separately and are not inflated into the LOC percentage.

## 9. Follow-up

- map each module to Git/source/package provenance;
- attach test/evidence IDs and architecture owner;
- keep embedded web-technology usage as a separate technology inventory;
- use module complexity/test/performance evidence in the knowledge-based questionnaire rather than relying on LOC alone.