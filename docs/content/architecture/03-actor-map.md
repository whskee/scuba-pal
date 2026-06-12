---
title: "Actor Map"
sidebar_label: "Actor Map"
sidebar_position: 4
slug: /architecture/actor-map
description: "The people, systems, clients, and providers that interact with Scuba Pal."
tags:
  - scuba-pal
  - actors
  - architecture
keywords:
  - "scuba-pal"
  - "actors"
  - "architecture"
---

# Actor map

```mermaid
flowchart LR
    Guest[Guest]
    Diver[Diver / User]
    Admin[Admin]
    Worker[System Worker]
    Web[Web Client / Thymeleaf]
    Mobile[Mobile Client / React Native Expo]
    Email[Email Provider]
    Storage[S3 Object Storage]

    Guest -->|views public pages| Web
    Diver -->|uses social + dive features| Web
    Diver -->|uses mobile app| Mobile
    Admin -->|manages platform| Web

    Web -->|calls controllers| Backend[Scuba Pal Backend]
    Mobile -->|calls REST API| Backend
    Worker -->|processes async jobs| Backend

    Backend -->|sends reset + notification emails| Email
    Backend -->|issues presigned uploads| Storage
    Mobile -->|uploads media directly| Storage
    Web -->|uploads media directly| Storage
```

## Actor responsibilities

| Actor | Responsibilities |
| --- | --- |
| Guest | Read public-facing pages, register, log in. |
| Diver/User | Manage profile, create posts, comment, follow, message, browse dive data, read learn content. |
| Admin | Moderate content, manage users, inspect platform stats. |
| System Worker | Send notifications, process events, clean stale uploads, run scheduled tasks. |
| Web Client | Browser UI served by the backend. |
| Mobile Client | React Native Expo app using generated OpenAPI client. |
| Email Provider | Sends account and notification emails. |
| Object Storage | Stores user-uploaded media. |

## Boundary rule

External providers should remain replaceable. The domain should know **that** an email or upload happened, not depend on a specific vendor model everywhere.
