---
title: "Permission Matrix"
sidebar_label: "Permissions"
sidebar_position: 12
slug: /architecture/permission-matrix
description: "Authorization truth for Scuba Pal by actor and role."
tags:
  - scuba-pal
  - security
  - permissions
keywords:
  - "scuba-pal"
  - "security"
  - "permissions"
---

# Permission matrix

| Action | Guest | User | Admin | Worker |
| --- | ---: | ---: | ---: | ---: |
| View public home page | Yes | Yes | Yes | No |
| Register | Yes | No | No | No |
| Login | Yes | No | No | No |
| Reset password | Yes | Yes | No | No |
| View own profile | No | Yes | Yes | No |
| Update own profile | No | Yes | Yes | No |
| View public profile | Yes | Yes | Yes | No |
| Create post | No | Yes | Yes | No |
| Edit own post | No | Yes | Yes | No |
| Delete own post | No | Yes | Yes | No |
| Moderate any post | No | No | Yes | No |
| Comment on post | No | Yes | Yes | No |
| Follow user | No | Yes | Yes | No |
| View feed | Limited | Yes | Yes | No |
| Start conversation | No | Yes | Yes | No |
| Send message | No | Yes | Yes | No |
| Read own notifications | No | Yes | Yes | No |
| Mark notification read | No | Yes | Yes | No |
| Request presigned upload | No | Yes | Yes | No |
| Browse dive locations | Yes | Yes | Yes | No |
| Manage dive locations | No | No | Yes | No |
| Browse dive shops | Yes | Yes | Yes | No |
| Manage dive shops | No | No | Yes | No |
| Read learn articles | Yes | Yes | Yes | No |
| Manage learn articles | No | No | Yes | No |
| View admin stats | No | No | Yes | No |
| Process notification jobs | No | No | No | Yes |
| Clean orphan media | No | No | No | Yes |

## Security rules

```mermaid
flowchart TD
    Request[Incoming Request] --> Public{Public endpoint?}
    Public -->|Yes| AllowPublic[Allow]
    Public -->|No| Auth{Authenticated?}
    Auth -->|No| Reject401[401 Unauthorized]
    Auth -->|Yes| Owner{Own resource?}
    Owner -->|Yes| AllowOwner[Allow]
    Owner -->|No| Admin{Admin role?}
    Admin -->|Yes| AllowAdmin[Allow]
    Admin -->|No| Worker{Worker token / internal job?}
    Worker -->|Yes| AllowWorker[Allow internal action]
    Worker -->|No| Reject403[403 Forbidden]
```

## Rule

Authorization should be tested at controller/service boundaries. Never rely only on hiding buttons in the UI.
