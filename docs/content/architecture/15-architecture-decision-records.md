---
title: "Architecture Decision Records"
sidebar_label: "ADRs"
sidebar_position: 16
slug: /architecture/adrs
description: "Architecture decisions for Scuba Pal and the reasons behind them."
tags:
  - scuba-pal
  - adr
  - architecture
keywords:
  - "scuba-pal"
  - "adr"
  - "architecture"
---

# Architecture Decision Records

Every major decision needs a short record so future you knows why the system looks the way it does.

## ADR-001: Use an internally modular Spring Boot backend

Status: Accepted

Context: Scuba Pal needs identity, social, messaging, dive, learn, media, notification, and admin features. Splitting services too early would add deployment and data consistency overhead.

Decision: Keep one Spring Boot deployable in `app`, with strong internal package boundaries.

Consequences:
- Simpler deployment and local development.
- Easier transactional consistency.
- Requires discipline to avoid package coupling.
- Future extraction remains possible around media, notifications, or messaging.

---

## ADR-002: Use PostgreSQL as the primary database

Status: Accepted

Context: The app has relational data: users, profiles, follows, posts, comments, conversations, messages, notifications, dive locations, and learn articles.

Decision: Use PostgreSQL with Flyway migrations.

Consequences:
- Strong constraints and joins.
- Clean reporting and admin visibility.
- Migration discipline is required.

---

## ADR-003: Use OpenAPI as the mobile contract

Status: Accepted

Context: The backend serves web and mobile. The mobile app should not drift from backend APIs.

Decision: Publish `/v3/api-docs` from the backend and generate the mobile client into `mobile/src/api/generated` after backend API changes.

Consequences:
- Less hand-written mobile API code.
- Breaking backend API changes surface earlier.
- Requires generated code refresh as part of workflow.

---

## ADR-004: Use S3-style direct media upload

Status: Accepted

Context: User-uploaded images should not unnecessarily pass through the backend app container.

Decision: Backend issues presigned upload URLs; web/mobile clients upload directly to object storage; backend persists media metadata.

Consequences:
- Better scalability for media uploads.
- Requires strict content type, metadata, key, and cleanup rules.
- Requires orphaned upload cleanup.

---

## ADR template

```md
# ADR-000: Decision title

Status: Proposed | Accepted | Superseded

Context:
What problem forced this decision?

Decision:
What did we choose?

Consequences:
- Positive outcome
- Tradeoff
- Follow-up work
```
