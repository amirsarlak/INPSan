# ADR-0010 — Notification Channels Disabled Until Acceptance

Status: `ACCEPTED`

## Context

Notification adapters can leak information, create alert storms, send incorrect messages or depend on credentials and external endpoints.

## Decision

Notification channels remain disabled until each channel has:

- secure secret handling;
- destination validation;
- retry/rate-limit behavior;
- deduplication and suppression tests;
- message-template review;
- failure-mode testing;
- explicit operational approval.

## Consequence

Alert Engine and dashboard alerting may operate without activating outbound notification delivery.
