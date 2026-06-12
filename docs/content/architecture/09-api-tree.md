---
title: "API Tree"
sidebar_label: "API Tree"
sidebar_position: 10
slug: /architecture/api-tree
description: "REST resource map for Scuba Pal and the OpenAPI contract used by the mobile generated client."
tags:
  - scuba-pal
  - api
  - openapi
keywords:
  - "scuba-pal"
  - "api"
  - "openapi"
---

# API tree

The backend OpenAPI contract is the source used to generate the mobile API client in `mobile/src/api/generated`.

```text
/api
  /auth
    POST /register
    POST /login
    POST /logout
    POST /forgot-password
    POST /reset-password

  /users
    GET /me
    GET /{userId}
    POST /{userId}/follow
    DELETE /{userId}/follow

  /profiles
    GET /me
    PATCH /me
    GET /{userId}

  /posts
    GET /
    POST /
    GET /{postId}
    PATCH /{postId}
    DELETE /{postId}
    POST /{postId}/comments
    GET /{postId}/comments

  /feed
    GET /

  /media
    POST /presign
    POST /complete
    GET /{mediaId}

  /conversations
    GET /
    POST /
    GET /{conversationId}
    POST /{conversationId}/messages
    PATCH /{conversationId}/read

  /notifications
    GET /
    PATCH /{notificationId}/read
    PATCH /read-all

  /dive-locations
    GET /
    GET /{locationId}

  /dive-shops
    GET /
    GET /{shopId}

  /learn
    GET /articles
    GET /articles/{slug}

  /admin
    GET /stats
    GET /users
    PATCH /users/{userId}/status
    PATCH /posts/{postId}/status

/actuator
  GET /health
  GET /health/liveness
  GET /health/readiness

/v3/api-docs
  GET /
```

## Contract workflow

```mermaid
flowchart LR
    Backend[Spring Boot Controllers + DTOs] --> OpenAPI[/v3/api-docs]
    OpenAPI --> Generator[openapi-generator]
    Generator --> MobileClient[mobile/src/api/generated]
    MobileClient --> MobileApp[React Native Expo App]
```

## API design rules

| Rule | Why |
| --- | --- |
| Resource names are plural | Matches database table convention and common REST style. |
| Mobile uses generated client | Prevents hand-written API drift. |
| DTOs are boundary objects | Avoid leaking JPA entities to clients. |
| Auth is explicit | Public, user, admin, and worker permissions must be obvious. |
| Errors are consistent | Mobile and web clients should handle failures predictably. |
