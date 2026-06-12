---
title: "Source of Truth Stack"
sidebar_label: "Source Stack"
sidebar_position: 1
slug: /architecture/source-of-truth-stack
description: "How Scuba Pal turns product ideas into domain models, APIs, database migrations, generated mobile clients, and implementation tasks."
tags:
  - scuba-pal
  - architecture
  - source-of-truth
keywords:
  - "scuba-pal"
  - "architecture"
  - "source-of-truth"
---

# Source of truth stack

Diagrams should not be random drawings. They should be views over deeper truth: product rules, domain language, lifecycle states, contracts, data, and decisions.

For Scuba Pal, the useful stack is:

```mermaid
flowchart TD
    A[Business Idea: Social Diving Platform] --> B[Product Brief]
    B --> C[Glossary]
    C --> D[Bounded Contexts]
    D --> E[Domain Model]
    E --> F[State Machines]
    E --> G[ERD / DBML / Flyway]
    E --> H[Commands + Events]
    F --> I[Use Cases]
    H --> I
    I --> J[Sequence Diagrams]
    I --> K[API Tree / OpenAPI]
    K --> L[Generated Mobile Client]
    G --> M[PostgreSQL Schemas]
    J --> N[Spring Boot Implementation]
    K --> N
    L --> O[React Native Expo App]
    N --> P[Deployment]
    P --> Q[Observability]
```

## Minimum complete system, minus implementation

| Source of truth | Scuba Pal answer |
| --- | --- |
| Product brief | Why divers use Scuba Pal and what the app owns. |
| Glossary | Shared vocabulary: user, profile, post, dive location, follow, conversation. |
| Actor map | Guest, diver, admin, system worker, external providers. |
| Domain model | Business objects and relationships before database details. |
| ERD / data model | PostgreSQL schemas, tables, keys, and constraints. |
| State machines | Legal lifecycles for accounts, posts, uploads, messages, notifications. |
| Use cases | What each actor can do. |
| Sequence diagrams | Step-by-step behavior for core flows. |
| API tree | REST resources and generated OpenAPI contract. |
| Event catalog | Facts emitted by the system. |
| Permission matrix | Authorization truth by role. |
| Screen map | Web and mobile screens derived from use cases. |
| System architecture | Runtime modules and dependencies. |
| Deployment diagram | Where everything runs locally and in cloud. |
| ADRs | Why key choices were made. |

## Rule of consistency

If `DiveLocation` exists in the glossary, it should appear in the domain model, ERD, API tree, screen map, authorization rules, and tests. If it only exists in code, the source of truth is incomplete.
