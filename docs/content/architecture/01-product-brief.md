---
title: "Product Brief"
sidebar_label: "Product Brief"
sidebar_position: 2
slug: /architecture/product-brief
description: "The top-level product truth for Scuba Pal: goal, actors, scope, core domains, and non-goals."
tags:
  - scuba-pal
  - product
  - architecture
keywords:
  - "scuba-pal"
  - "product"
  - "architecture"
---

# Product Brief

## System

**Scuba Pal** — a social platform for scuba divers.

## Goal

Help divers build a profile, share diving-related posts, discover dive locations and dive shops, follow other divers, message each other, receive notifications, upload media, and learn through structured content.

## Primary actors

| Actor | Meaning |
| --- | --- |
| Guest | Unauthenticated visitor browsing public pages. |
| Diver/User | Authenticated person using Scuba Pal. |
| Admin | Operator who manages users, content, and platform health. |
| System Worker | Background process for events, notifications, cleanup, and async jobs. |
| Email Provider | External mail delivery provider. |
| Object Storage Provider | S3-compatible storage for user media. |
| Mobile Client | React Native Expo application using generated OpenAPI client code. |

## Core domains

- Identity and authentication
- Profiles
- Social posts and comments
- Follows and feed
- Messaging
- Notifications
- Dive locations
- Dive shops
- Learn articles
- Media uploads
- Admin and platform operations

## In scope

- Web experience through Spring Boot + Thymeleaf.
- REST API documented through OpenAPI.
- React Native Expo mobile app using generated client code in `mobile/src/api/generated`.
- PostgreSQL-backed persistent data.
- S3-style object storage for media.
- Flyway migrations as database change history.

## Out of scope for the first production cut

- Marketplace payments.
- Dive computer integrations.
- Certification authority integrations.
- Complex recommendation ML.
- Multi-region active-active deployment.

## Success criteria

| Area | Success signal |
| --- | --- |
| Product | A diver can register, complete a profile, post, follow, discover, and message. |
| Backend | OpenAPI, database migrations, and code stay aligned. |
| Mobile | Generated API client can be refreshed after backend contract changes. |
| Operations | Health checks, logs, metrics, and deployment workflow are repeatable. |
| Architecture | Docs explain the system faster than reading the whole codebase. |
