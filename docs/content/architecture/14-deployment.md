---
title: "Deployment"
sidebar_label: "Deployment"
sidebar_position: 15
slug: /architecture/deployment
description: "Local and cloud deployment shape for Scuba Pal across backend, mobile, database, object storage, and observability."
tags:
  - scuba-pal
  - deployment
  - aws
keywords:
  - "scuba-pal"
  - "deployment"
  - "aws"
---

# Deployment diagram

## Production target

```mermaid
flowchart TD
    User[User Browser]
    MobileUser[Mobile User]

    subgraph AWS[AWS]
        DNS[DNS]
        CDN[CDN / Static Assets]
        LB[Application Load Balancer]
        App[ECS/Fargate App Container]
        RDS[(RDS PostgreSQL)]
        S3[(S3 Media Bucket)]
        Logs[(CloudWatch Logs / Metrics)]
        Secrets[Secrets Manager / Parameter Store]
    end

    Email[Email Provider]
    AppStore[Mobile App Distribution]

    User --> DNS
    DNS --> CDN
    DNS --> LB
    MobileUser --> AppStore
    MobileUser --> LB
    CDN --> LB
    LB --> App
    App --> RDS
    App --> S3
    App --> Logs
    App --> Secrets
    App --> Email
    MobileUser -->|presigned PUT| S3
    User -->|presigned PUT| S3
```

## Local development

```mermaid
flowchart LR
    Dev[Developer Mac]
    Backend[app: Spring Boot]
    Mobile[mobile: Expo]
    PG[(Local PostgreSQL)]
    Mail[Mailpit]
    Docs[docs: Docusaurus]

    Dev --> Backend
    Dev --> Mobile
    Dev --> Docs
    Backend --> PG
    Backend --> Mail
    Mobile --> Backend
```

## Runtime configuration

| Concern | Local | Production |
| --- | --- | --- |
| Database | Docker PostgreSQL | RDS PostgreSQL |
| Media | Local/S3 dev bucket | S3 bucket |
| Mail | Mailpit | Email provider |
| Secrets | `.env`, shell env | Secrets Manager / Parameter Store |
| Health | Actuator health endpoints | ALB/ECS health checks |
| Logs | Console | CloudWatch |
| API contract | `/v3/api-docs` | Versioned OpenAPI artifact + endpoint |

## Deployment rule

Deploy the backend only when migrations, health checks, OpenAPI generation, and smoke tests are part of the workflow.

```mermaid
flowchart LR
    Commit[Git Commit] --> CI[CI Build]
    CI --> Test[Tests]
    Test --> Image[Docker Image]
    Image --> Migrate[Flyway Migration]
    Migrate --> Deploy[ECS Deploy]
    Deploy --> Health[Health Check]
    Health --> Generate[Refresh OpenAPI Client]
```
