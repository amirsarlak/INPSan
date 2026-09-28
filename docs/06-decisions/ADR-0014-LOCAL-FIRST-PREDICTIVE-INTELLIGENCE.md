# ADR-0014 — Local-First Predictive Intelligence

Status: **ACCEPTED AS R&D ARCHITECTURE**  
Date: 2026-09-28

## Decision

INPSan predictive analytics will process operational telemetry and metadata locally by default and will not require disclosure of customer payload data to a cloud service.

Development order:
1. data-quality validation;
2. deterministic baselines;
3. feature engineering;
4. anomaly detection;
5. forecasting/failure-risk models;
6. model registry, explainability and drift control.

Observed faults, anomalies, forecasts and recommendations remain separate semantic classes.

## Consequences

- no current AI capability claim until implementation and validation;
- privacy and data-minimization are architectural constraints;
- model confidence and contributing signals must be exposed;
- false-positive/false-negative rates become acceptance metrics;
- a dedicated analytics runtime may be introduced without forcing unrelated modules to change language/runtime.