```mermaid
sequenceDiagram
    autonumber
    Actor Client
    participant Controller
    participant Request
    participant Response
    participant Mapper
    participant Service
    participant DAO as DAO/Impl
    participant Repository
    participant Database

    Client->>Controller: POST /users (UserRequest)
    activate Controller
    
    Controller->>Request: new UserRequest(username, email)
    
    Controller->>Mapper: mapToEntity(UserRequest)
    activate Mapper
    Mapper-->>Controller: User (Entity)
    deactivate Mapper

    Controller->>Service: createUser(User)
    activate Service
    
    Service->>DAO: save(User)
    activate DAO
    DAO->>Repository: save(User)
    activate Repository
    Repository->>Database: INSERT INTO users
    Database-->>Repository: Saved User Entity
    Repository-->>DAO: User (Entity)
    deactivate Repository
    DAO-->>Service: User (Entity)
    deactivate DAO

    Service->>Mapper: mapToDTO(User)
    activate Mapper
    Mapper-->>Service: UserResponse (DTO)
    deactivate Mapper

    Service-->>Controller: UserResponse (DTO)
    deactivate Service

    Controller->>Response: new UserResponse(id, username, email)
    
    Controller-->>Client: 201 Created (UserResponse)
    deactivate Controller
```


flowchart TD
    Controller[Controller] --> Service[Service]
    Service --> User[AppUser aggregate root]
    User --> Credentials[LoginCredentials embedded value object]
    Service --> Repository[Repository]
    Repository --> DB[(Database)]

    Mapper[Mapper] --> User
    Mapper --> DTO[UserResponse DTO]

    Controller -. should not touch .-> Credentials
    Mapper -. should not expose .-> PasswordHash[password_hash]
