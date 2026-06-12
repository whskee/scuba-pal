---
title: "Domain Model"
sidebar_label: "Domain Model"
sidebar_position: 5
slug: /architecture/domain-model
description: "Conceptual Scuba Pal domain objects and relationships before implementation or database details."
tags:
  - scuba-pal
  - domain-model
  - architecture
keywords:
  - "scuba-pal"
  - "domain-model"
  - "architecture"
---

# Domain model

This is the conceptual model before table names, controllers, or DTOs.

```mermaid
classDiagram
    class User {
        userId
        email
        passwordHash
        status
        createdAt
    }

    class Profile {
        profileId
        displayName
        bio
        avatarUrl
        certificationLevel
    }

    class Role {
        name
    }

    class Post {
        postId
        authorId
        body
        visibility
        status
        createdAt
    }

    class Comment {
        commentId
        postId
        authorId
        body
        status
        createdAt
    }

    class Follow {
        followerId
        followedId
        status
        createdAt
    }

    class Conversation {
        conversationId
        createdAt
    }

    class Message {
        messageId
        senderId
        body
        status
        sentAt
        readAt
    }

    class Notification {
        notificationId
        recipientId
        type
        status
        createdAt
        readAt
    }

    class DiveLocation {
        locationId
        name
        region
        latitude
        longitude
        difficulty
    }

    class DiveShop {
        shopId
        name
        city
        website
        phone
    }

    class LearnArticle {
        articleId
        title
        slug
        status
        publishedAt
    }

    class MediaObject {
        mediaId
        ownerId
        objectKey
        contentType
        purpose
        status
    }

    User "1" --> "1" Profile
    User "*" --> "*" Role
    User "1" --> "0..*" Post
    User "1" --> "0..*" Comment
    User "1" --> "0..*" Follow : follower
    User "1" --> "0..*" Follow : followed
    Post "1" --> "0..*" Comment
    Post "1" --> "0..*" MediaObject
    User "1" --> "0..*" Conversation
    Conversation "1" --> "1..*" Message
    User "1" --> "0..*" Message
    User "1" --> "0..*" Notification
    DiveLocation "0..*" --> "0..*" Post : referenced by
    DiveShop "0..*" --> "0..*" DiveLocation : serves area
    User "1" --> "0..*" MediaObject
```

## Bounded contexts

| Context | Owns |
| --- | --- |
| Identity | Users, credentials, roles, auth flows. |
| Profile | Public diver profile and avatar. |
| Social | Posts, comments, follows, feed. |
| Messaging | Conversations, participants, messages, unread counts. |
| Notification | Notification records and delivery state. |
| Dive | Dive locations and dive shops. |
| Learn | Educational articles and content. |
| Media | Presigned uploads, object keys, content-type rules, upload purpose. |
| Admin | Platform visibility and operational controls. |

## Design rule

For the first production version, keep this as an **internally modular monolith**. Split services later only when deployment, scaling, or team ownership creates real pressure.
