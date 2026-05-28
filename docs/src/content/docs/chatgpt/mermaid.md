---
title: Mermaid Diagrams
description: A reference page in my new Starlight docs site.
---

Diagramming is powerful. Never understimate good diagrams.

Anything else:
Where applicable, always provide mermaid diagrams because diagrams help me understand and learn stuff better. Flow, connections, use case, system, any other diagrams relevant to understand the material decide etc. 

```mermaid
graph TD
    %% Styling
    classDef client fill:#f9f,stroke:#333,stroke-width:2px;
    classDef presentation fill:#bbf,stroke:#333,stroke-width:2px;
    classDef business fill:#bfb,stroke:#333,stroke-width:2px;
    classDef data fill:#fbb,stroke:#333,stroke-width:2px;
    classDef storage fill:#eee,stroke:#333,stroke-width:2px;

    %% Client / Browser
    subgraph Client_Side ["Client Side (Browser)"]
        HTML[HTML - Structure]:::client
        CSS[CSS - Styles]:::client
        JS[JavaScript - Fetch / AJAX]:::client
    end

    %% Presentation Layer
    subgraph Presentation_Layer ["Presentation / Web Layer"]
        WebCtrl[Web Controller<br/>Returns Views]:::presentation
        ApiCtrl[API Controller<br/>Returns JSON/Data]:::presentation
        View[View / Template<br/>Thymeleaf/JSP]:::presentation
        DTO[DTO<br/>Data Transfer Object]:::presentation
    end

    %% Business Layer
    subgraph Business_Layer ["Business Logic Layer"]
        Service[Service Class<br/>Business Rules]:::business
    end

    %% Data Access Layer
    subgraph Data_Layer ["Data Access / Persistence Layer"]
        Repo[Repository / DAO<br/>Spring Data / Hibernate]:::data
        Entity[Entity / Domain Model<br/>Maps to Database Table]:::data
    end

    %% Database
    Database[(Database<br/>SQL / NoSQL)]:::storage

    %% --- FLOW & CONNECTIONS ---

    %% Web Request Flow
    HTML -->|1a. Page Request| WebCtrl
    WebCtrl -->|2a. Call Business Logic| Service
    Service -->|3a. Return Domain Data| WebCtrl
    WebCtrl -->|4a. Render Data into HTML| View
    View -->|5a. Return Complete Web Page| HTML
    CSS -.->|Style| View

    %% API Request Flow
    JS -->|1b. API Request / JSON| ApiCtrl
    DTO -.->|Maps Incoming JSON| ApiCtrl
    ApiCtrl -->|2b. Pass DTO Data| Service
    Service -->|3b. Return Result DTO| ApiCtrl
    ApiCtrl -->|4b. Send JSON Response| JS

    %% Backend Internal Flow
    Service -->|Interact with DB| Repo
    Repo -->|Handles Query/Mapping| Entity
    Repo <-->|Read / Write SQL| Database
    Entity <-.->|Maps Table Rows| Database

    %% Cross-Layer Data Mapping
    Entity -.->|Map to DTO| Service
```


