---
title: "State Machines"
sidebar_label: "State Machines"
sidebar_position: 7
slug: /architecture/state-machines
description: "Legal lifecycle states for Scuba Pal accounts, media uploads, posts, messages, and notifications."
tags:
  - scuba-pal
  - state-machines
  - architecture
keywords:
  - "scuba-pal"
  - "state-machines"
  - "architecture"
---

# State machines

State machines prevent scattered `if status == ...` logic and make illegal transitions obvious.

## User account lifecycle

```mermaid
stateDiagram-v2
    [*] --> Registered
    Registered --> EmailVerificationPending
    EmailVerificationPending --> Active: email verified
    EmailVerificationPending --> Suspended: abuse detected
    Active --> PasswordResetPending: reset requested
    PasswordResetPending --> Active: password changed
    Active --> Suspended: admin action
    Suspended --> Active: admin restores
    Active --> Deleted: user/admin deletes
    Suspended --> Deleted
    Deleted --> [*]
```

## Media upload lifecycle

```mermaid
stateDiagram-v2
    [*] --> PresignRequested
    PresignRequested --> PresignIssued
    PresignIssued --> Uploading: client PUT to object storage
    Uploading --> Uploaded: object exists
    Uploaded --> Attached: linked to post/profile
    PresignIssued --> Expired: not used in time
    Uploaded --> Orphaned: never attached
    Orphaned --> Deleted: cleanup job
    Attached --> Deleted: owner/admin removes
    Deleted --> [*]
```

## Post lifecycle

```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Published: user posts
    Published --> Edited: user edits
    Edited --> Published
    Published --> Hidden: moderation/admin action
    Hidden --> Published: restored
    Published --> Deleted: owner/admin deletes
    Hidden --> Deleted
    Deleted --> [*]
```

## Message lifecycle

```mermaid
stateDiagram-v2
    [*] --> Sent
    Sent --> Delivered: conversation persisted
    Delivered --> Read: recipient opens conversation
    Sent --> Failed: persistence/delivery failure
    Failed --> Retried
    Retried --> Delivered
    Read --> [*]
```

## Notification lifecycle

```mermaid
stateDiagram-v2
    [*] --> Created
    Created --> Delivered
    Delivered --> Read
    Created --> Expired
    Read --> Archived
    Expired --> Archived
    Archived --> [*]
```
