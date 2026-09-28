# INPSan Performance & Resource Benchmark Specification v1.0

Status: **ACTIVE SPECIFICATION — harness implementation pending**  
Date: 2026-09-28

## Objective

Quantify INPSan software overhead and define evidence-based performance budgets before adding new 3.3 services.

## Test profiles
1. **Idle** — no intentional application I/O.
2. **Normal** — representative steady workload.
3. **High I/O** — controlled load in a test environment.
4. **Degraded** — selected non-destructive degradation conditions.
5. **Recovery** — service restart/recovery and state stabilization.
6. **Soak** — long-duration observation.

Intrusive/destructive load is prohibited on production data.

## Metrics

### Host/resource
- total CPU;
- per-INPSan-service CPU;
- RSS/virtual memory;
- ARC size/pressure context;
- load average.

### Storage overhead
- pool/device IOPS and throughput;
- telemetry/history write rate;
- history storage growth per day;
- additional I/O attributable to monitoring where measurable.

### Service quality
- collector cycle duration;
- telemetry freshness success rate;
- alert engine cycle/processing latency;
- DataAdapter response latency;
- dashboard/API p50/p95/p99 once instrumented;
- startup time-to-ready;
- service restart/recovery time.

### Future 3.3 components
- Control Plane request latency;
- authentication/RBAC overhead;
- report-generation cost;
- Predictive Engine inference latency/RAM/CPU;
- Central Manager node/metric/event scale.

## Evidence

Each run records product version/build, host/software baseline, profile, timestamps, commands/tool versions, raw outputs, summarized metrics, anomalies and interpretation.
PASS/FAIL is assigned only against an approved performance budget.

## Initial acceptance

The first benchmark cycle establishes the 3.2.x reference baseline. It does not invent pass/fail thresholds before measurement.