For Scuba Pal, “all this” becomes your **Architecture Contract**: the human-readable and machine-readable truth that code must follow. Your current repo truth is: root repo `scuba-pal`, backend in `app` with Java Spring Boot + Thymeleaf using Java 25, mobile in `mobile` with React Native Expo, and generated mobile API client in `mobile/src/api/generated` after OpenAPI updates. 

Progress: **45% — Scuba Pal source-of-truth map drafted**
Next goal: create `docs/architecture/00-product-brief.md` through `06-api-tree.md` first.

---

# Scuba Pal source-of-truth stack

```mermaid
flowchart TD
    A[Scuba Pal Product Idea] --> B[Glossary]
    B --> C[Bounded Contexts]
    C --> D[Domain Model]
    D --> E[State Machines]
    D --> F[ERD / DBML / Flyway]
    D --> G[Commands + Events]
    E --> H[Use Cases]
    G --> H
    H --> I[Sequence Diagrams]
    H --> J[OpenAPI Contract]
    J --> K[Generated Mobile Client]
    F --> L[PostgreSQL Schemas]
    I --> M[Backend Implementation]
    J --> M
    K --> N[React Native Expo App]
    M --> O[Deployment]
```

The important rule from your architecture template is: diagrams are not random drawings; they are views over deeper truth like domain model, state model, contracts, data model, and decisions. 

---

# 1. Product brief

```md
# Scuba Pal Product Brief

System:
Scuba Pal

Goal:
A social platform for scuba divers to create profiles, share posts, discover dive locations,
follow other divers, message each other, receive notifications, and learn through dive content.

Primary actors:
- Guest
- Diver/User
- Admin
- System Worker
- Email Provider
- Object Storage Provider

Core domains:
- Identity
- Profiles
- Social Posts
- Follows
- Messaging
- Notifications
- Dive Locations
- Dive Shops
- Learn Content
- Media Uploads
- Admin
```

---

# 2. Glossary

| Term          | Meaning                                                  |
| ------------- | -------------------------------------------------------- |
| User          | Authenticated account holder.                            |
| Profile       | Public diver-facing identity: bio, image, diver details. |
| Post          | Social content created by a user.                        |
| Comment       | Reply attached to a post.                                |
| Follow        | Relationship where one user follows another.             |
| Feed          | Ordered collection of posts relevant to a user.          |
| Conversation  | Messaging thread between users.                          |
| Message       | Individual text payload inside a conversation.           |
| Notification  | User-visible system alert.                               |
| Dive Location | Place where divers can dive.                             |
| Dive Shop     | Business/resource related to diving.                     |
| Learn Article | Educational scuba content.                               |
| Media Object  | Uploaded image/file stored in object storage.            |
| Admin         | User with elevated system-management permissions.        |

Golden rule:

> If Scuba Pal has a noun, it should appear in the glossary, domain model, ERD, API tree, screen map, permissions, and tests.

---

# 3. Actors

```mermaid
flowchart LR
    Guest[Guest]
    Diver[Diver / Authenticated User]
    Admin[Admin]
    Worker[System Worker]
    Email[Email Provider]
    S3[Object Storage / S3]

    Guest -->|registers / logs in / views public content| ScubaPal[Scuba Pal]
    Diver -->|posts, follows, messages, explores dives| ScubaPal
    Admin -->|manages users, content, stats| ScubaPal
    Worker -->|sends notifications / processes events| ScubaPal
    ScubaPal -->|stores media| S3
    ScubaPal -->|sends email| Email
```

---

# 4. Bounded contexts

For Scuba Pal, these are your clean module boundaries.

```mermaid
flowchart TD
    subgraph ScubaPal[Scuba Pal Backend]
        Identity[Identity Context]
        Profile[Profile Context]
        Social[Social Context]
        Messaging[Messaging Context]
        Notification[Notification Context]
        Dive[Dive Directory Context]
        Learn[Learn Context]
        Media[Media Context]
        Admin[Admin Context]
        Shared[Shared Kernel]
    end

    Identity --> Profile
    Identity --> Social
    Identity --> Messaging
    Identity --> Notification

    Profile --> Social
    Profile --> Messaging

    Social --> Notification
    Messaging --> Notification
    Media --> Profile
    Media --> Social
    Dive --> Social
    Learn --> Admin
    Admin --> Identity
    Admin --> Social
    Admin --> Dive
```

**Interpretation:**

| Context      | Owns                                                           |
| ------------ | -------------------------------------------------------------- |
| Identity     | users, credentials, roles, login, registration, password reset |
| Profile      | diver profile, bio, avatar, public user identity               |
| Social       | posts, comments, follows, feed                                 |
| Messaging    | conversations, messages, unread counts                         |
| Notification | notifications and read/unread lifecycle                        |
| Dive         | dive locations, dive shops, map/search/filter                  |
| Learn        | educational articles                                           |
| Media        | presigned uploads, object keys, image metadata                 |
| Admin        | stats, moderation, management                                  |
| Shared       | exceptions, security helpers, config, base types               |

---

# 5. Domain model

```mermaid
classDiagram
    class User {
        UUID id
        email
        passwordHash
        status
        createdAt
    }

    class Role {
        UUID id
        name
    }

    class Profile {
        UUID id
        displayName
        bio
        avatarUrl
        certificationLevel
    }

    class Post {
        UUID id
        body
        mediaUrl
        status
        createdAt
    }

    class Comment {
        UUID id
        body
        createdAt
    }

    class Follow {
        UUID followerId
        UUID followingId
        createdAt
    }

    class Conversation {
        UUID id
        createdAt
        updatedAt
    }

    class Message {
        UUID id
        body
        readAt
        createdAt
    }

    class Notification {
        UUID id
        type
        title
        body
        readAt
        createdAt
    }

    class DiveLocation {
        UUID id
        name
        city
        country
        difficulty
        visibility
    }

    class DiveShop {
        UUID id
        name
        city
        website
    }

    class LearnArticle {
        UUID id
        title
        slug
        status
        publishedAt
    }

    class MediaObject {
        UUID id
        objectKey
        contentType
        uploadPurpose
        status
    }

    User "1" --> "1" Profile
    User "*" --> "*" Role
    User "1" --> "0..*" Post
    User "1" --> "0..*" Comment
    User "1" --> "0..*" Notification
    User "1" --> "0..*" Message
    User "1" --> "0..*" MediaObject

    Post "1" --> "0..*" Comment
    User "1" --> "0..*" Follow : follower
    User "1" --> "0..*" Follow : following

    Conversation "1" --> "1..*" Message
    Message "*" --> "1" User : sender

    DiveLocation "1" --> "0..*" DiveShop
    LearnArticle "*" --> "1" User : author
    Post "0..*" --> "0..1" DiveLocation
```

---

# 6. ERD / database model

This is the rough Scuba Pal ERD. Your actual source should eventually become `database/schema.dbml` plus Flyway migrations.

```mermaid
erDiagram
    users {
        uuid id PK
        string email UK
        string password_hash
        string status
        timestamp created_at
    }

    roles {
        uuid id PK
        string name UK
    }

    user_roles {
        uuid user_id FK
        uuid role_id FK
    }

    profiles {
        uuid id PK
        uuid user_id FK
        string display_name
        text bio
        string avatar_url
        string certification_level
    }

    posts {
        uuid id PK
        uuid author_id FK
        text body
        string media_url
        string status
        timestamp created_at
    }

    comments {
        uuid id PK
        uuid post_id FK
        uuid author_id FK
        text body
        timestamp created_at
    }

    follows {
        uuid follower_id FK
        uuid following_id FK
        timestamp created_at
    }

    conversations {
        uuid id PK
        timestamp created_at
        timestamp updated_at
    }

    conversation_participants {
        uuid conversation_id FK
        uuid user_id FK
    }

    messages {
        uuid id PK
        uuid conversation_id FK
        uuid sender_id FK
        text body
        timestamp read_at
        timestamp created_at
    }

    notifications {
        uuid id PK
        uuid user_id FK
        string type
        string title
        text body
        timestamp read_at
        timestamp created_at
    }

    dive_locations {
        uuid id PK
        string name
        string city
        string country
        string difficulty
        decimal latitude
        decimal longitude
    }

    dive_shops {
        uuid id PK
        uuid dive_location_id FK
        string name
        string website
        string city
    }

    learn_articles {
        uuid id PK
        uuid author_id FK
        string title
        string slug UK
        string status
        timestamp published_at
    }

    media_objects {
        uuid id PK
        uuid uploader_user_id FK
        string object_key UK
        string content_type
        string upload_purpose
        string status
        timestamp created_at
    }

    users ||--|| profiles : owns
    users ||--o{ posts : creates
    users ||--o{ comments : writes
    posts ||--o{ comments : has
    users ||--o{ notifications : receives
    users ||--o{ messages : sends
    conversations ||--o{ messages : contains
    conversations ||--o{ conversation_participants : has
    users ||--o{ conversation_participants : joins
    users ||--o{ follows : follower
    users ||--o{ follows : following
    users ||--o{ media_objects : uploads
    users ||--o{ learn_articles : authors
    dive_locations ||--o{ dive_shops : has
```

---

# 7. State machines

## User lifecycle

```mermaid
stateDiagram-v2
    [*] --> Registered
    Registered --> EmailVerificationPending
    EmailVerificationPending --> Active: email verified
    Registered --> Active: verification not required
    Active --> PasswordResetRequested
    PasswordResetRequested --> Active: password reset completed
    Active --> Suspended: admin suspends
    Suspended --> Active: admin restores
    Active --> Deleted: user deletes account
    Suspended --> Deleted: admin deletes account
    Deleted --> [*]
```

## Post lifecycle

```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Published: user posts
    Published --> Edited: user edits
    Edited --> Published: save changes
    Published --> Hidden: moderation/admin action
    Hidden --> Published: restored
    Published --> Deleted: author/admin deletes
    Hidden --> Deleted
    Deleted --> [*]
```

## Media upload lifecycle

```mermaid
stateDiagram-v2
    [*] --> Requested
    Requested --> PresignedUrlIssued
    PresignedUrlIssued --> UploadedToS3
    UploadedToS3 --> Attached: linked to profile/post
    UploadedToS3 --> Orphaned: not attached before expiry
    Orphaned --> Deleted
    Attached --> Deleted
    Deleted --> [*]
```

## Message lifecycle

```mermaid
stateDiagram-v2
    [*] --> Sent
    Sent --> Delivered
    Delivered --> Read
    Sent --> DeletedBySender
    Delivered --> DeletedBySender
    Read --> DeletedBySender
    DeletedBySender --> [*]
```

## Notification lifecycle

```mermaid
stateDiagram-v2
    [*] --> Created
    Created --> Unread
    Unread --> Read: user opens / marks read
    Read --> Archived
    Unread --> Archived
    Archived --> [*]
```

---

# 8. Use cases

```mermaid
flowchart LR
    Guest[Guest]
    Diver[Diver]
    Admin[Admin]

    UC1[Register account]
    UC2[Login]
    UC3[Create profile]
    UC4[Upload profile image]
    UC5[Create post]
    UC6[Comment on post]
    UC7[Follow diver]
    UC8[View feed]
    UC9[Send message]
    UC10[View notifications]
    UC11[Explore dive locations]
    UC12[View dive shops]
    UC13[Read learn articles]
    UC14[Manage users]
    UC15[Moderate content]
    UC16[View admin stats]

    Guest --> UC1
    Guest --> UC2
    Guest --> UC11
    Guest --> UC13

    Diver --> UC3
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

    Admin --> UC14
    Admin --> UC15
    Admin --> UC16
```

---

# 9. API tree

OpenAPI should be the machine-readable truth. That matters extra for you because your mobile client is generated from backend OpenAPI into `mobile/src/api/generated`. 

```mermaid
flowchart TD
    API[/api/v1/]

    API --> Auth[/auth/]
    Auth --> Register[POST /auth/register]
    Auth --> Login[POST /auth/login]
    Auth --> Logout[POST /auth/logout]
    Auth --> Forgot[POST /auth/forgot-password]
    Auth --> Reset[POST /auth/reset-password]

    API --> Me[/me/]
    Me --> GetMe[GET /me]
    Me --> UpdateMe[PATCH /me]

    API --> Profiles[/profiles/]
    Profiles --> GetProfile[GET /profiles/{userId}]
    Profiles --> UpdateProfile[PATCH /profiles/me]

    API --> Posts[/posts/]
    Posts --> ListPosts[GET /posts]
    Posts --> CreatePost[POST /posts]
    Posts --> GetPost[GET /posts/{postId}]
    Posts --> UpdatePost[PATCH /posts/{postId}]
    Posts --> DeletePost[DELETE /posts/{postId}]

    API --> Feed[/feed/]
    Feed --> GetFeed[GET /feed]

    API --> Comments[/posts/{postId}/comments/]
    Comments --> CreateComment[POST /posts/{postId}/comments]
    Comments --> DeleteComment[DELETE /posts/{postId}/comments/{commentId}]

    API --> Follows[/follows/]
    Follows --> Follow[POST /follows/{userId}]
    Follows --> Unfollow[DELETE /follows/{userId}]
    Follows --> Followers[GET /users/{userId}/followers]
    Follows --> Following[GET /users/{userId}/following]

    API --> Messaging[/messaging/]
    Messaging --> Conversations[GET /messaging/conversations]
    Messaging --> CreateConversation[POST /messaging/conversations]
    Messaging --> GetMessages[GET /messaging/conversations/{conversationId}/messages]
    Messaging --> SendMessage[POST /messaging/conversations/{conversationId}/messages]

    API --> Notifications[/notifications/]
    Notifications --> ListNotifications[GET /notifications]
    Notifications --> MarkRead[POST /notifications/{notificationId}/read]

    API --> DiveLocations[/dive-locations/]
    DiveLocations --> ListLocations[GET /dive-locations]
    DiveLocations --> GetLocation[GET /dive-locations/{locationId}]

    API --> DiveShops[/dive-shops/]
    DiveShops --> ListShops[GET /dive-shops]
    DiveShops --> GetShop[GET /dive-shops/{shopId}]

    API --> Media[/media/]
    Media --> Presign[POST /media/presigned-upload]
    Media --> Attach[POST /media/{mediaId}/attach]

    API --> Learn[/learn/]
    Learn --> ListArticles[GET /learn/articles]
    Learn --> GetArticle[GET /learn/articles/{slug}]

    API --> Admin[/admin/]
    Admin --> Stats[GET /admin/stats]
    Admin --> Users[GET /admin/users]
```

---

# 10. Event catalog

| Event                    | Meaning                      | Producer     | Consumers                    |
| ------------------------ | ---------------------------- | ------------ | ---------------------------- |
| `UserRegistered`         | New user account created     | Identity     | Notification, Analytics      |
| `PasswordResetRequested` | User requested reset         | Identity     | Email                        |
| `ProfileUpdated`         | User changed profile         | Profile      | Feed/Search cache            |
| `MediaUploadRequested`   | Presigned upload started     | Media        | Audit/cleanup worker         |
| `MediaAttached`          | Media linked to post/profile | Media        | Social/Profile               |
| `PostCreated`            | User created post            | Social       | Feed, Notification           |
| `PostCommented`          | User commented on post       | Social       | Notification                 |
| `UserFollowed`           | User followed another user   | Social       | Notification                 |
| `ConversationCreated`    | New message thread opened    | Messaging    | Notification                 |
| `MessageSent`            | Message created              | Messaging    | Notification, unread counter |
| `NotificationRead`       | User read notification       | Notification | Analytics                    |
| `DiveLocationCreated`    | New location added           | Dive         | Search/Map index             |
| `LearnArticlePublished`  | Article became public        | Learn        | Feed/Notification optional   |

```mermaid
flowchart LR
    Identity[Identity]
    Profile[Profile]
    Social[Social]
    Messaging[Messaging]
    Media[Media]
    Dive[Dive]
    Learn[Learn]
    EventBus[(Application Events)]
    Notification[Notification]
    Email[Email Sender]
    Feed[Feed Builder]
    Analytics[Analytics]
    Cleanup[Media Cleanup Worker]

    Identity -->|UserRegistered| EventBus
    Identity -->|PasswordResetRequested| EventBus
    Profile -->|ProfileUpdated| EventBus
    Social -->|PostCreated / PostCommented / UserFollowed| EventBus
    Messaging -->|MessageSent| EventBus
    Media -->|MediaUploadRequested / MediaAttached| EventBus
    Dive -->|DiveLocationCreated| EventBus
    Learn -->|LearnArticlePublished| EventBus

    EventBus --> Notification
    EventBus --> Email
    EventBus --> Feed
    EventBus --> Analytics
    EventBus --> Cleanup
```

For now this can be Spring application events. Later it can become RabbitMQ/Kafka if Scuba Pal grows.

---

# 11. Permission matrix

| Action                   | Guest | User | Admin |
| ------------------------ | ----: | ---: | ----: |
| View public landing page |   Yes |  Yes |   Yes |
| Register                 |   Yes |   No |    No |
| Login                    |   Yes |   No |    No |
| View public profiles     |   Yes |  Yes |   Yes |
| Edit own profile         |    No |  Yes |   Yes |
| Create post              |    No |  Yes |   Yes |
| Edit own post            |    No |  Yes |   Yes |
| Delete own post          |    No |  Yes |   Yes |
| Delete any post          |    No |   No |   Yes |
| Comment                  |    No |  Yes |   Yes |
| Follow user              |    No |  Yes |   Yes |
| Message user             |    No |  Yes |   Yes |
| View own conversations   |    No |  Yes |   Yes |
| View notifications       |    No |  Yes |   Yes |
| Explore dive locations   |   Yes |  Yes |   Yes |
| Manage dive locations    |    No |   No |   Yes |
| Manage learn articles    |    No |   No |   Yes |
| View admin stats         |    No |   No |   Yes |

---

# 12. Screen map

```mermaid
flowchart TD
    Landing[Landing Page]
    Login[Login]
    Register[Register]
    ForgotPassword[Forgot Password]
    ResetPassword[Reset Password]

    HomeFeed[Home Feed]
    Profile[Profile]
    EditProfile[Edit Profile]
    CreatePost[Create Post]
    PostDetail[Post Detail]
    Notifications[Notifications]

    Messages[Messages]
    Conversation[Conversation]

    DiveMap[Dive Map]
    DiveLocations[Dive Locations]
    DiveLocationDetail[Dive Location Detail]
    DiveShops[Dive Shops]
    DiveShopDetail[Dive Shop Detail]

    Learn[Learn]
    LearnArticle[Learn Article]

    AdminDashboard[Admin Dashboard]
    AdminUsers[Admin Users]
    AdminContent[Admin Content]

    Landing --> Login
    Landing --> Register
    Login --> HomeFeed
    Register --> EditProfile
    Login --> ForgotPassword
    ForgotPassword --> ResetPassword

    HomeFeed --> Profile
    HomeFeed --> CreatePost
    HomeFeed --> PostDetail
    HomeFeed --> Notifications
    HomeFeed --> DiveMap
    HomeFeed --> Learn
    HomeFeed --> Messages

    Profile --> EditProfile
    Profile --> Messages
    PostDetail --> Profile

    Messages --> Conversation

    DiveMap --> DiveLocations
    DiveLocations --> DiveLocationDetail
    DiveLocationDetail --> DiveShops
    DiveShops --> DiveShopDetail

    Learn --> LearnArticle

    AdminDashboard --> AdminUsers
    AdminDashboard --> AdminContent
```

---

# 13. System architecture

```mermaid
flowchart TD
    subgraph Clients
        Browser[Browser / Thymeleaf Web]
        Mobile[React Native Expo Mobile]
    end

    subgraph Backend[Spring Boot App]
        Controllers[Controllers]
        Services[Application Services]
        Domain[Domain Modules]
        Repositories[JPA Repositories]
        Events[Spring Events]
        Security[Spring Security]
        OpenAPI[OpenAPI Contract]
    end

    subgraph Data
        Postgres[(PostgreSQL)]
        Flyway[Flyway Migrations]
        S3[(S3 Object Storage)]
    end

    subgraph External
        EmailProvider[SMTP / Mail Provider]
    end

    Browser --> Controllers
    Mobile --> OpenAPI
    Mobile --> Controllers

    Controllers --> Security
    Controllers --> Services
    Services --> Domain
    Services --> Repositories
    Services --> Events

    Repositories --> Postgres
    Flyway --> Postgres
    Services --> S3
    Services --> EmailProvider

    OpenAPI --> GeneratedClient[mobile/src/api/generated]
```

This should stay a **modular monolith** first. You do not need microservices yet. Your modules should be clean enough that future extraction is possible, but the deployable should remain simple.

---

# 14. Deployment diagram

```mermaid
flowchart TD
    User[User Browser / Mobile App]

    subgraph AWS[AWS]
        ALB[Application Load Balancer]
        ECS[ECS Fargate Task]
        App[Spring Boot Container]
        RDS[(RDS PostgreSQL)]
        S3[(S3 Bucket)]
        Secrets[Secrets Manager / SSM]
        Logs[CloudWatch Logs]
    end

    subgraph LocalDev[Local Development]
        Docker[Docker Compose]
        LocalPostgres[(Local PostgreSQL)]
        Mailpit[Mailpit]
    end

    User --> ALB
    ALB --> ECS
    ECS --> App

    App --> RDS
    App --> S3
    App --> Secrets
    App --> Logs

    Docker --> LocalPostgres
    Docker --> Mailpit
```

---

# 15. Recommended Scuba Pal docs structure

```text
scuba-pal/
  app/
    src/
    pom.xml

  mobile/
    src/
      api/
        generated/

  docs/
    architecture/
      00-product-brief.md
      01-glossary.md
      02-actors.md
      03-context-map.md
      04-domain-model.md
      05-erd.md
      06-state-machines.md
      07-use-cases.md
      08-sequence-diagrams.md
      09-api-tree.md
      10-event-catalog.md
      11-permissions.md
      12-screen-map.md
      13-system-architecture.md
      14-deployment.md
      15-observability.md
      16-risks.md
      adr/
        ADR-001-use-modular-monolith.md
        ADR-002-use-postgresql.md
        ADR-003-use-openapi-for-mobile-client.md
        ADR-004-use-s3-presigned-uploads.md
        ADR-005-use-react-native-expo-for-mobile.md

  contracts/
    openapi.yaml
    asyncapi.yaml

  database/
    schema.dbml
    migrations/

  diagrams/
    context-map.mmd
    domain-model.mmd
    erd.mmd
    user-state-machine.mmd
    post-state-machine.mmd
    message-sequence.mmd
    media-upload-sequence.mmd
```

Your uploaded architecture template recommends this exact kind of separation: architecture docs, machine-readable contracts, database schema, migrations, and diagrams. 

---

# The minimum Scuba Pal source of truth

Do these first:

```text
00-product-brief.md
01-glossary.md
02-context-map.md
03-domain-model.md
04-erd.md
05-state-machines.md
06-api-tree.md
```

After that, add:

```text
07-sequence-diagrams.md
08-event-catalog.md
09-permissions.md
10-screen-map.md
```

Then implementation becomes much easier because every file answers one question:

```mermaid
flowchart TD
    Glossary[What words exist?]
    Domain[What objects exist?]
    ERD[How are they stored?]
    States[How do they change?]
    API[How do clients access them?]
    Screens[Where does user see them?]
    Code[How is it implemented?]

    Glossary --> Domain
    Domain --> ERD
    Domain --> States
    States --> API
    API --> Screens
    ERD --> Code
    API --> Code
    Screens --> Code
```

# Best next move

Create `docs/architecture/01-glossary.md` and lock the nouns first:

```text
User
Profile
Post
Comment
Follow
Feed
Conversation
Message
Notification
DiveLocation
DiveShop
LearnArticle
MediaObject
Admin
```

Once those are stable, Scuba Pal stops feeling like “many folders and features” and starts feeling like one coherent system.
