---
title: "System Architecture"
sidebar_label: "System Architecture"
sidebar_position: 14
slug: /architecture/system-architecture
description: "Scuba Pal runtime architecture across web, mobile, Spring Boot modules, PostgreSQL, object storage, and OpenAPI generation."
tags:
  - scuba-pal
  - system-architecture
  - spring-boot
keywords:
  - "scuba-pal"
  - "system-architecture"
  - "spring-boot"
---

# System architecture diagram

Scuba Pal should start as an internally modular monolith with clean package/module boundaries.

```mermaid
flowchart TD
    subgraph Clients
        Browser[Browser / Thymeleaf Web]
        Mobile[React Native Expo Mobile]
    end

    subgraph Backend[app: Spring Boot Java 25]
        WebMVC[Web MVC Controllers]
        RestAPI[REST Controllers]
        Security[Spring Security]
        Identity[Identity Module]
        Profile[Profile Module]
        Social[Social Module]
        Messaging[Messaging Module]
        Notification[Notification Module]
        Dive[Dive Module]
        Learn[Learn Module]
        Media[Media Module]
        Admin[Admin Module]
        OpenAPI[OpenAPI Docs]
    end

    subgraph Data
        PG[(PostgreSQL)]
        Flyway[Flyway Migrations]
        Storage[(S3 Object Storage)]
    end

    subgraph External
        Email[Email Provider]
    end

    subgraph Generated[Generated Contracts]
        APIJSON["/v3/api-docs"]
        MobileClient[mobile/src/api/generated]
    end

    Browser --> WebMVC
    Browser --> RestAPI
    Mobile --> RestAPI
    RestAPI --> Security
    WebMVC --> Security

    Security --> Identity
    Identity --> PG
    Profile --> PG
    Social --> PG
    Messaging --> PG
    Notification --> PG
    Dive --> PG
    Learn --> PG
    Admin --> PG
    Media --> Storage
    Media --> PG
    Notification --> Email

    Flyway --> PG
    OpenAPI --> APIJSON
    APIJSON --> MobileClient
    MobileClient --> Mobile
```

## Module dependency rule

```mermaid
flowchart LR
    Controllers[Controllers / Pages] --> Application[Application Services]
    Application --> Domain[Domain Model]
    Application --> Repositories[Repositories]
    Repositories --> Database[(PostgreSQL)]
    Application --> Integrations[Email / S3 / OpenAPI]
```

Keep dependency direction inward. Controllers should orchestrate request/response, not hold business rules.

## Suggested backend package shape

```text
app/src/main/java/com/scubapal
  identity/
  profile/
  social/
  messaging/
  notification/
  dive/
  learn/
  media/
  admin/
  shared/
```

## Split-service candidates later

| Candidate service | Split only when |
| --- | --- |
| Media service | Upload volume, malware scanning, or CDN invalidation grows. |
| Notification service | Delivery retry complexity becomes independent. |
| Messaging service | Real-time requirements require WebSocket scaling. |
| Dive catalog service | Dive data becomes separately owned/imported. |

For now, prefer one deployable backend with strong internal boundaries.
