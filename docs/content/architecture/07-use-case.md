---
title: "Use Cases"
sidebar_label: "Use Cases"
sidebar_position: 8
slug: /architecture/use-cases
description: "Scuba Pal capabilities from each actor perspective."
tags:
  - scuba-pal
  - use-cases
  - architecture
keywords:
  - "scuba-pal"
  - "use-cases"
  - "architecture"
---

# Use cases

```mermaid
flowchart LR
    Guest[Guest]
    Diver[Diver / User]
    Admin[Admin]
    Worker[System Worker]

    UC1[Register]
    UC2[Log in / log out]
    UC3[Reset password]
    UC4[Manage profile]
    UC5[Create post]
    UC6[Comment on post]
    UC7[Follow diver]
    UC8[View feed]
    UC9[Browse dive locations]
    UC10[Browse dive shops]
    UC11[Read learn articles]
    UC12[Start conversation]
    UC13[Send message]
    UC14[Read notifications]
    UC15[Upload media]
    UC16[Moderate users/content]
    UC17[View admin stats]
    UC18[Process async notifications]
    UC19[Clean stale uploads]

    Guest --> UC1
    Guest --> UC2
    Guest --> UC3
    Guest --> UC9
    Guest --> UC10
    Guest --> UC11

    Diver --> UC4
    Diver --> UC5
    Diver --> UC6
    Diver --> UC7
    Diver --> UC8
    Diver --> UC9
    Diver --> UC10
    Diver --> UC11
    Diver --> UC12
    Diver --> UC13
    Diver --> UC14
    Diver --> UC15

    Admin --> UC16
    Admin --> UC17

    Worker --> UC18
    Worker --> UC19
```

## Core capability table

| Capability | Guest | Diver/User | Admin | Worker |
| --- | ---: | ---: | ---: | ---: |
| Register | Yes | No | No | No |
| Log in | Yes | No | No | No |
| Manage own profile | No | Yes | No | No |
| Create post | No | Yes | Yes | No |
| Comment | No | Yes | Yes | No |
| Follow / unfollow | No | Yes | No | No |
| View feed | Limited | Yes | Yes | No |
| Browse dive locations | Yes | Yes | Yes | No |
| Browse dive shops | Yes | Yes | Yes | No |
| Read learn content | Yes | Yes | Yes | No |
| Start conversation | No | Yes | Yes | No |
| Send message | No | Yes | Yes | No |
| Read notifications | No | Yes | Yes | No |
| Upload media | No | Yes | Yes | No |
| Moderate content | No | No | Yes | No |
| Process events | No | No | No | Yes |

## Rule

Every use case should eventually map to a screen, endpoint, permission rule, test case, and at least one sequence diagram for critical flows.
