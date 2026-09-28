# INPSAN-TE-KB-SOURCE-CENSUS-2026-09-28

Type: **Test & Evidence**
Parent: `CP-KB-001` / `WP-3.3-001`

## Evidence
- Source Census v0.1.0-dev completed successfully.
- 114 deployment files inventoried by metadata/hash.
- No source contents exported by the census.
- Raw census normalized to remove historical/backup duplication, fixtures, metadata and full upstream integration-host files.
- Current normalized programming set: 43 code files / 7,419 LOC.
- File-primary-language result: Perl 7,149 LOC (96.36%), Shell 270 LOC (3.64%).
- 13 current INPSan module groups identified.

## Result
**PASS — initial module/source census and normalization.**

## Constraint
Embedded web technologies inside Perl files are not semantically segmented by this evidence and therefore are not assigned an LOC percentage.