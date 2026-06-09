



Below is the **Scuba Pal architecture map** as a clean “current + production-ready direction” set of Mermaid diagrams.

I’m grounding this in your project note: root repo is `scuba-pal`, backend is `app` using Java Spring Boot + Thymeleaf, mobile is `mobile` using React Native Expo, and backend OpenAPI updates generate the mobile client into `mobile/src/api/generated`. fileciteturn2file0 Your local deployment checkpoint already proved Docker, container startup, PostgreSQL, Flyway/JPA, S3 config, Mailpit config, Spring Security health access, liveness, readiness, and overall health. fileciteturn2file1

Progress: **85% architecture mapped**.  
Next goal: turn these into `/docs/architecture/*.mdx` pages and keep each diagram close to the code module it explains.

---

# 1. Whole Scuba Pal system architecture

```mermaid
flowchart TB
    User["Diver / User"]
    AdminUser["Admin"]
    Browser["Web Browser"]
    MobileApp["React Native Expo App"]

    subgraph Repo["scuba-pal"]
        Backend["app<br/>Spring Boot + Thymeleaf<br/>Java 25"]
        Mobile["mobile<br/>React Native Expo"]
        GeneratedClient["mobile/src/api/generated<br/>OpenAPI Generated Client"]
    end

    subgraph BackendLayers["Backend Runtime"]
        Controllers["Controllers<br/>REST + Web MVC"]
        Services["Application Services"]
        Domain["Domain Modules"]
        Repositories["Repositories / JPA"]
        Thymeleaf["Thymeleaf Views"]
        Security["Spring Security"]
        OpenAPI["OpenAPI Spec<br/>/v3/api-docs"]
        Actuator["Actuator<br/>health / liveness / readiness"]
    end

    subgraph Data["Persistence + External Systems"]
        Postgres["PostgreSQL"]
        Flyway["Flyway Migrations"]
        S3["AWS S3<br/>media storage"]
        Mail["Mailpit local<br/>SMTP provider prod"]
    end

    User --> Browser
    User --> MobileApp
    AdminUser --> Browser

    Browser -->|"HTML pages / forms"| Backend
    MobileApp -->|"uses"| GeneratedClient
    GeneratedClient -->|"REST API"| Backend

    Backend --> Security
    Backend --> Controllers
    Controllers --> Services
    Services --> Domain
    Domain --> Repositories
    Repositories --> Postgres

    Backend --> Thymeleaf
    Backend --> OpenAPI
    Backend --> Actuator

    Flyway --> Postgres
    Backend --> S3
    Backend --> Mail
```

---

# 2. Repository / codebase architecture

```mermaid
flowchart TB
    Root["scuba-pal"]

    Root --> App["app<br/>Spring Boot Backend"]
    Root --> Mobile["mobile<br/>React Native Expo"]
    Root --> Docs["docs / architecture notes"]
    Root --> Infra["infra / docker / deployment"]

    App --> Java["src/main/java/com/scubapal"]
    App --> Resources["src/main/resources"]
    App --> Migrations["db/migration<br/>Flyway SQL"]
    App --> Templates["templates<br/>Thymeleaf"]
    App --> Static["static<br/>CSS / JS / images"]
    App --> Dockerfile["Dockerfile"]
    App --> Pom["pom.xml"]

    Mobile --> Expo["Expo App"]
    Mobile --> Screens["screens / navigation"]
    Mobile --> ApiGenerated["src/api/generated"]
    Mobile --> ApiWrapper["src/api/client wrappers"]
    Mobile --> MobileState["auth/session/state"]

    App --> OpenAPISpec["/v3/api-docs"]
    OpenAPISpec -->|"openapi-generator"| ApiGenerated
```

Core idea: **backend owns the contract**, mobile consumes the generated client. Do not hand-write duplicated API types in mobile unless you are wrapping generated calls into cleaner app-specific hooks/services.

---

# 3. Backend modular monolith architecture

This is the best fit right now. You get clean boundaries without paying microservice complexity too early.

```mermaid
flowchart TB
    subgraph App["Spring Boot App"]
        Shared["shared<br/>config, security, errors, utils"]
        Identity["identity<br/>users, auth, roles"]
        Social["social<br/>profiles, posts, comments, follows, feed"]
        Dive["dive<br/>locations, shops, maps"]
        Certification["certification<br/>certs, agencies, levels"]
        Media["media<br/>S3 presigned uploads"]
        Messaging["messaging<br/>conversations, messages"]
        Notification["notification<br/>in-app + email events"]
        Learn["learn<br/>articles, educational content"]
        Admin["admin<br/>stats, moderation, ops"]
    end

    Shared --> Identity
    Shared --> Social
    Shared --> Dive
    Shared --> Certification
    Shared --> Media
    Shared --> Messaging
    Shared --> Notification
    Shared --> Learn
    Shared --> Admin

    Identity --> Social
    Identity --> Messaging
    Identity --> Notification
    Social --> Media
    Social --> Notification
    Messaging --> Notification
    Dive --> Media
    Certification --> Identity
    Learn --> Media
    Admin --> Identity
    Admin --> Social
    Admin --> Dive
```

Rule of thumb: each module should have its own:

```text
controller
service
repository
entity
dto
mapper
event
```

But do not force every folder if the module is tiny. Grow structure from actual complexity.

---

# 4. Backend request lifecycle

```mermaid
sequenceDiagram
    actor User
    participant Browser as Browser / Mobile
    participant Security as Spring Security
    participant Controller as Controller
    participant Service as Application Service
    participant Domain as Domain Logic
    participant Repo as Repository
    participant DB as PostgreSQL
    participant External as S3 / Mail / Other

    User->>Browser: Performs action
    Browser->>Security: HTTP request
    Security->>Security: Authenticate + authorize
    Security->>Controller: Forward allowed request
    Controller->>Service: Validate command/query
    Service->>Domain: Apply business rules
    Domain->>Repo: Load/save aggregate/data
    Repo->>DB: SQL via JPA
    DB-->>Repo: Result
    Repo-->>Domain: Entity/data
    Domain-->>Service: Business result

    alt External side effect needed
        Service->>External: Upload URL / email / notification
        External-->>Service: Result
    end

    Service-->>Controller: DTO/view model
    Controller-->>Browser: JSON API or Thymeleaf page
```

The big production principle: controllers should stay thin. The **service layer owns workflows**, and the **domain/module layer owns business rules**.

---

# 5. Web + mobile API boundary

```mermaid
flowchart LR
    subgraph WebClient["Web Client"]
        Browser["Browser"]
        ThymeleafPages["Server-rendered Thymeleaf Pages"]
    end

    subgraph MobileClient["Mobile Client"]
        Expo["React Native Expo"]
        GeneratedAPI["Generated OpenAPI Client"]
        MobileServices["Mobile API Wrappers / Hooks"]
    end

    subgraph Backend["Spring Boot Backend"]
        WebControllers["Web MVC Controllers"]
        RestControllers["REST Controllers"]
        Auth["Authentication / Authorization"]
        OpenAPI["OpenAPI Contract"]
        AppServices["Application Services"]
    end

    Browser -->|"GET pages / POST forms"| WebControllers
    WebControllers --> ThymeleafPages
    ThymeleafPages --> Browser

    Expo --> MobileServices
    MobileServices --> GeneratedAPI
    GeneratedAPI -->|"REST JSON"| RestControllers

    WebControllers --> Auth
    RestControllers --> Auth
    WebControllers --> AppServices
    RestControllers --> AppServices

    RestControllers --> OpenAPI
    OpenAPI --> GeneratedAPI
```

Long-term clean rule:

```text
Web controllers = page rendering
REST controllers = API contract
Services = shared business workflows
```

That keeps your Thymeleaf web app and mobile app from drifting into two different products.

---

# 6. Authentication architecture

```mermaid
flowchart TB
    User["User"]

    subgraph Client["Client"]
        Web["Browser"]
        Mobile["Mobile App"]
    end

    subgraph Backend["Spring Security Boundary"]
        AuthController["Auth Controller / API"]
        SecurityFilter["Security Filter Chain"]
        AuthService["Auth Service"]
        PasswordEncoder["Password Encoder"]
        UserRepo["User Repository"]
        SessionOrToken["Session / Token Strategy"]
    end

    DB["PostgreSQL users / roles"]

    User --> Web
    User --> Mobile

    Web -->|"login form"| SecurityFilter
    Mobile -->|"login API"| AuthController

    SecurityFilter --> AuthService
    AuthController --> AuthService

    AuthService --> UserRepo
    UserRepo --> DB
    AuthService --> PasswordEncoder
    AuthService --> SessionOrToken

    SessionOrToken --> Web
    SessionOrToken --> Mobile
```

Important: do **not** casually add JWT unless you need stateless auth across multiple backend instances or external clients. For now:

```text
Web: session cookie is natural.
Mobile: use the backend's explicit auth contract.
Production later: choose either session-backed API auth or token auth intentionally.
```

---

# 7. OpenAPI generation lifecycle

```mermaid
sequenceDiagram
    participant Backend as Spring Boot Backend
    participant Spec as /v3/api-docs
    participant Generator as openapi-generator
    participant MobileGenerated as mobile/src/api/generated
    participant MobileApp as React Native Expo App

    Backend->>Spec: Exposes current API contract
    Spec->>Generator: Download JSON spec
    Generator->>MobileGenerated: Generate TypeScript client
    MobileGenerated->>MobileApp: Imported by API wrappers/hooks
    MobileApp->>Backend: Calls backend through generated client
```

This is one of your strongest architectural decisions. It prevents this common failure:

```text
Backend changes endpoint
Mobile silently keeps old request shape
Runtime breaks later
```

Generated clients make API drift visible earlier.

---

# 8. Media upload architecture with S3

```mermaid
sequenceDiagram
    actor User
    participant MobileOrWeb as Mobile / Web Client
    participant Backend as Spring Boot Media API
    participant Auth as Spring Security
    participant S3 as AWS S3
    participant DB as PostgreSQL

    User->>MobileOrWeb: Select image
    MobileOrWeb->>Backend: Request presigned upload URL
    Backend->>Auth: Verify user and upload purpose
    Auth-->>Backend: Authorized
    Backend->>S3: Create presigned PUT URL
    S3-->>Backend: Presigned URL
    Backend-->>MobileOrWeb: Upload URL + object key

    MobileOrWeb->>S3: PUT image directly to S3
    S3-->>MobileOrWeb: Upload success

    MobileOrWeb->>Backend: Confirm uploaded media key
    Backend->>DB: Save media reference / attach to entity
    Backend-->>MobileOrWeb: Media available
```

Why this is good:

```text
Client uploads large file directly to S3.
Backend controls authorization and object keys.
Database stores references, not image bytes.
```

---

# 9. Social/feed architecture

```mermaid
flowchart TB
    User["User"]

    subgraph SocialModule["social module"]
        ProfileController["Profile Controller/API"]
        PostController["Post Controller/API"]
        FollowController["Follow Controller/API"]
        FeedController["Feed Controller/API"]

        ProfileService["Profile Service"]
        PostService["Post Service"]
        FollowService["Follow Service"]
        FeedService["Feed Service"]

        Posts["posts"]
        Comments["comments"]
        Follows["follows"]
        Profiles["profiles"]
    end

    DB["PostgreSQL"]
    Media["media module"]
    Notification["notification module"]

    User --> ProfileController
    User --> PostController
    User --> FollowController
    User --> FeedController

    ProfileController --> ProfileService
    PostController --> PostService
    FollowController --> FollowService
    FeedController --> FeedService

    ProfileService --> Profiles
    PostService --> Posts
    PostService --> Comments
    FollowService --> Follows
    FeedService --> Posts
    FeedService --> Follows
    FeedService --> Profiles

    Posts --> DB
    Comments --> DB
    Follows --> DB
    Profiles --> DB

    PostService --> Media
    PostService --> Notification
    FollowService --> Notification
```

Feed can start simple:

```text
Query posts from followed users + own posts + recent public posts.
```

Later, once traffic grows:

```text
Precomputed feed table
Event-driven fanout
Ranking service
Caching layer
```

Do not start with a complex feed system until the simple one is painful.

---

# 10. Messaging + notification architecture

```mermaid
sequenceDiagram
    actor Sender
    participant Client as Web/Mobile Client
    participant MessagingAPI as Messaging API
    participant MessagingService as Messaging Service
    participant DB as PostgreSQL
    participant NotificationService as Notification Service
    participant Recipient as Recipient Client
    participant Mail as Email Provider

    Sender->>Client: Sends message
    Client->>MessagingAPI: POST /messages
    MessagingAPI->>MessagingService: sendMessage(command)
    MessagingService->>DB: Save message
    MessagingService->>DB: Update conversation unread count
    MessagingService->>NotificationService: MessageCreated event

    NotificationService->>DB: Save in-app notification

    alt Recipient online
        NotificationService-->>Recipient: Realtime/poll notification
    else Recipient offline
        NotificationService->>Mail: Optional email notification
    end

    MessagingAPI-->>Client: Message sent
```

Current simple version:

```text
Persist messages.
Expose unread counts.
Mobile/web polls or refreshes.
```

Production evolution:

```text
Domain event -> queue -> notification worker -> push/email/websocket.
```

---

# 11. Event-driven production direction

This is the **future shape**, not something you need to split into microservices yet.

```mermaid
flowchart LR
    subgraph ModularMonolith["Spring Boot Modular Monolith"]
        Social["social"]
        Messaging["messaging"]
        Certification["certification"]
        Dive["dive"]
        Identity["identity"]
    end

    subgraph EventLayer["Event Layer"]
        DomainEvents["Domain Events"]
        Outbox["Transactional Outbox"]
        Queue["Kafka / RabbitMQ later"]
    end

    subgraph Consumers["Async Consumers"]
        NotificationWorker["Notification Worker"]
        EmailWorker["Email Worker"]
        SearchIndexer["Search Indexer later"]
        AnalyticsWorker["Analytics Worker later"]
    end

    DB["PostgreSQL"]
    Mail["Mail Provider"]
    Push["Push Notifications later"]
    Search["Search Engine later"]

    Social --> DomainEvents
    Messaging --> DomainEvents
    Certification --> DomainEvents
    Dive --> DomainEvents
    Identity --> DomainEvents

    DomainEvents --> Outbox
    Outbox --> DB
    Outbox --> Queue

    Queue --> NotificationWorker
    Queue --> EmailWorker
    Queue --> SearchIndexer
    Queue --> AnalyticsWorker

    NotificationWorker --> DB
    NotificationWorker --> Push
    EmailWorker --> Mail
    SearchIndexer --> Search
```

Best long-term sequence:

```text
1. Start with in-process Spring events.
2. Add transactional outbox table.
3. Add background publisher.
4. Add RabbitMQ/Kafka only when async pressure is real.
5. Split services only after module boundaries are stable.
```

---

# 12. Database bounded-context architecture

```mermaid
erDiagram
    USERS ||--o| PROFILES : has
    USERS ||--o{ POSTS : creates
    USERS ||--o{ COMMENTS : writes
    USERS ||--o{ FOLLOWS : follower
    USERS ||--o{ FOLLOWS : followed
    USERS ||--o{ CONVERSATION_MEMBERS : joins
    USERS ||--o{ MESSAGES : sends
    USERS ||--o{ NOTIFICATIONS : receives
    USERS ||--o{ CERTIFICATIONS : owns

    POSTS ||--o{ COMMENTS : has
    POSTS ||--o{ MEDIA_OBJECTS : attaches
    PROFILES ||--o{ MEDIA_OBJECTS : avatar

    CONVERSATIONS ||--o{ CONVERSATION_MEMBERS : has
    CONVERSATIONS ||--o{ MESSAGES : contains

    DIVE_LOCATIONS ||--o{ DIVE_SHOPS : nearby
    DIVE_LOCATIONS ||--o{ MEDIA_OBJECTS : has

    LEARN_ARTICLES ||--o{ MEDIA_OBJECTS : includes

    USERS {
        uuid id
        string email
        string password_hash
        string role
        datetime created_at
    }

    PROFILES {
        uuid id
        uuid user_id
        string display_name
        string bio
        string location
    }

    POSTS {
        uuid id
        uuid author_user_id
        string body
        datetime created_at
    }

    COMMENTS {
        uuid id
        uuid post_id
        uuid author_user_id
        string body
    }

    FOLLOWS {
        uuid follower_user_id
        uuid followed_user_id
    }

    MEDIA_OBJECTS {
        uuid id
        string bucket
        string object_key
        string content_type
        string purpose
    }

    CONVERSATIONS {
        uuid id
        datetime created_at
    }

    MESSAGES {
        uuid id
        uuid conversation_id
        uuid sender_user_id
        string body
        datetime sent_at
    }

    NOTIFICATIONS {
        uuid id
        uuid recipient_user_id
        string type
        boolean read
    }

    DIVE_LOCATIONS {
        uuid id
        string name
        decimal latitude
        decimal longitude
    }

    DIVE_SHOPS {
        uuid id
        string name
        uuid location_id
    }

    CERTIFICATIONS {
        uuid id
        uuid user_id
        string agency
        string level
    }

    LEARN_ARTICLES {
        uuid id
        string title
        string slug
    }
```

This is not meant to be a perfect database dump. It is the **mental model** for how the system hangs together.

---

# 13. Local development architecture

```mermaid
flowchart TB
    Dev["You on MacBook"]

    subgraph Local["Local Machine"]
        IDE["IntelliJ / VS Code"]
        Docker["Docker / OrbStack"]
        BackendContainer["scuba-pal app container"]
        PostgresContainer["PostgreSQL container"]
        PgAdmin["pgAdmin / DataGrip"]
        Mailpit["Mailpit"]
    end

    subgraph ExternalOptional["Optional External Dev Services"]
        S3Dev["AWS S3 dev bucket"]
    end

    Dev --> IDE
    IDE --> BackendContainer
    Docker --> BackendContainer
    Docker --> PostgresContainer
    Docker --> Mailpit
    PgAdmin --> PostgresContainer

    BackendContainer --> PostgresContainer
    BackendContainer --> Mailpit
    BackendContainer --> S3Dev

    BackendContainer --> Health["/actuator/health<br/>/actuator/health/liveness<br/>/actuator/health/readiness"]
```

Your local checkpoint is strong because it proves the app does not just compile; it boots with infrastructure dependencies.

---

# 14. AWS deployment architecture target

```mermaid
flowchart TB
    User["Users"]
    DNS["Domain / Route 53"]
    CDN["CloudFront later<br/>optional"]
    ALB["Application Load Balancer"]

    subgraph AWS["AWS"]
        subgraph VPC["VPC"]
            subgraph PublicSubnets["Public Subnets"]
                ALB
            end

            subgraph PrivateSubnets["Private Subnets"]
                ECS["ECS Fargate Service<br/>Spring Boot Container"]
                RDS["RDS PostgreSQL"]
            end

            S3["S3 Bucket<br/>media"]
            Secrets["Secrets Manager / SSM"]
            Logs["CloudWatch Logs"]
            ECR["ECR Image Registry"]
        end
    end

    User --> DNS
    DNS --> CDN
    CDN --> ALB
    DNS --> ALB

    ALB --> ECS
    ECS --> RDS
    ECS --> S3
    ECS --> Secrets
    ECS --> Logs
    ECR --> ECS

    ECS --> Readiness["Health check:<br/>/actuator/health/readiness"]
```

Production deployment order:

```text
1. Build Docker image.
2. Push image to ECR.
3. ECS task pulls image.
4. ECS injects secrets/env vars.
5. App connects to RDS + S3.
6. ALB routes traffic only to healthy readiness endpoint.
```

---

# 15. Final clean architecture mental model

```mermaid
flowchart TB
    UI["User Interfaces<br/>Thymeleaf Web + React Native Expo"]

    API["API Boundary<br/>Web MVC + REST + OpenAPI"]

    Application["Application Layer<br/>Use cases / workflows"]

    Domain["Domain Modules<br/>identity, social, dive, media,<br/>messaging, notifications, learn"]

    Infrastructure["Infrastructure<br/>JPA, PostgreSQL, S3, Mail,<br/>Security, Actuator"]

    Deployment["Deployment<br/>Docker, ECR, ECS Fargate,<br/>RDS, CloudWatch"]

    UI --> API
    API --> Application
    Application --> Domain
    Domain --> Infrastructure
    Infrastructure --> Deployment
```

The key idea:

```text
Scuba Pal should stay a modular monolith until its modules are stable.
The backend owns the product rules.
OpenAPI keeps mobile aligned.
PostgreSQL is the system of record.
S3 owns media bytes.
Events should begin inside the monolith before becoming queues.
```

Next best goal: **create `docs/architecture/index.mdx` and paste diagrams 1, 2, 3, 5, 8, 11, and 14 first.** Those give you the strongest architecture documentation without overwhelming the reader.
