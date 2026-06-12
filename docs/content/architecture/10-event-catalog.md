---
title: "Event Catalog"
sidebar_label: "Event Catalog"
sidebar_position: 11
slug: /architecture/event-catalog
description: "Domain events and async facts emitted by Scuba Pal."
tags:
  - scuba-pal
  - events
  - architecture
keywords:
  - "scuba-pal"
  - "events"
  - "architecture"
---

# Event catalog

Events are facts that already happened. They should be named in past tense.

```mermaid
flowchart TD
    Auth[Identity] --> UserRegistered[UserRegistered]
    Social[Social] --> PostCreated[PostCreated]
    Social --> CommentCreated[CommentCreated]
    Social --> FollowCreated[FollowCreated]
    Messaging[Messaging] --> MessageSent[MessageSent]
    Media[Media] --> MediaUploaded[MediaUploaded]
    Notification[Notification] --> NotificationCreated[NotificationCreated]

    UserRegistered --> Email[Email Delivery]
    PostCreated --> Feed[Feed Refresh / Cache Invalidation]
    CommentCreated --> NotifyAuthor[Notify Post Author]
    FollowCreated --> NotifyFollowed[Notify Followed User]
    MessageSent --> NotifyRecipient[Notify Message Recipient]
    MediaUploaded --> Cleanup[Orphan Cleanup Tracking]
```

## Events

| Event | Producer | Consumers | Minimal payload |
| --- | --- | --- | --- |
| `UserRegistered` | Identity | Email, analytics, admin stats | `userId`, `email`, `createdAt` |
| `ProfileUpdated` | Profile | Feed, search/indexing later | `userId`, `profileId`, `changedFields`, `updatedAt` |
| `PostCreated` | Social | Feed, notifications, moderation | `postId`, `authorId`, `visibility`, `createdAt` |
| `PostDeleted` | Social | Feed, notifications, media cleanup | `postId`, `authorId`, `deletedAt` |
| `CommentCreated` | Social | Notifications | `commentId`, `postId`, `authorId`, `createdAt` |
| `FollowCreated` | Social | Notifications, feed | `followerId`, `followedId`, `createdAt` |
| `FollowRemoved` | Social | Feed | `followerId`, `followedId`, `removedAt` |
| `MessageSent` | Messaging | Notifications, unread counts | `messageId`, `conversationId`, `senderId`, `recipientIds`, `sentAt` |
| `ConversationRead` | Messaging | Unread counts | `conversationId`, `userId`, `readAt` |
| `NotificationRead` | Notification | Analytics later | `notificationId`, `recipientId`, `readAt` |
| `MediaPresignIssued` | Media | Audit, cleanup | `mediaId`, `ownerId`, `objectKey`, `expiresAt` |
| `MediaUploaded` | Media | Validation, cleanup | `mediaId`, `ownerId`, `objectKey`, `uploadedAt` |
| `LearnArticlePublished` | Learn | Feed/search later | `articleId`, `slug`, `publishedAt` |

## Rule

Start with in-process events inside the Spring Boot app. Move to Kafka/RabbitMQ only when async volume or service boundaries require it.
