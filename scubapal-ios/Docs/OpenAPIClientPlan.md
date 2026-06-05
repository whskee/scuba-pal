# OpenAPI Client Migration Plan

## Current State

An OpenAPI spec already exists in the iOS tree:

- `OpenAPI/scubapal-openapi.json`
- `Packages/ScubaPalAPI/Sources/ScubaPalAPI/openapi.json`

There is also a Swift package scaffold at `Packages/ScubaPalAPI` using Apple's Swift OpenAPI Generator with `types` and `client` generation enabled in `openapi-generator-config.yaml`.

The app target still uses hand-written networking:

- `Core/Networking/APIClient.swift`
- `API/Endpoints/APIPath.swift`
- `API/DTO/*.swift`
- `API/Mappers/*.swift`
- feature repositories that wrap `APIClient`

## Safe Migration Direction

Keep SwiftUI isolated from generated API models. Repositories should remain the boundary between generated transport models and app domain models.

Target dependency direction:

```text
SwiftUI Views
  -> ViewModels
  -> Repository protocols
  -> Repository implementations
  -> Generated ScubaPalAPI client/types
  -> HTTP transport

Repository implementations
  -> API/Mappers
  -> Domain/Models
```

## Generated Output Folder

Prefer keeping generated code inside the existing package:

```text
Packages/ScubaPalAPI/
  Sources/ScubaPalAPI/
    openapi.json
    openapi-generator-config.yaml
    ScubaPalAPIModule.swift
```

The app target should import `ScubaPalAPI` only from repository implementations. Views, view models, and `Domain/Models` should not import it.

## What Should Remain Hand-Written

- `Domain/Models`: app-facing models used by SwiftUI.
- `API/Mappers`: conversions from generated API shapes to domain models.
- Repository protocols: test and preview boundaries.
- `AppDependencies`: live and preview composition.
- Preview repositories and sample data.
- Auth/session ownership and token storage.

## What Should Become Generated

- Request/response transport models currently in `API/DTO`.
- Endpoint operation methods currently represented by `APIPath` plus `Endpoint`.
- Some low-level request construction currently handled by hand-written repository calls.

Do this endpoint family by endpoint family, not all at once. A good first migration slice is a read-only area such as Learn or Dive Locations.

## Repository Wrapping Pattern

Each repository should keep the same protocol while switching its implementation internally:

```swift
struct GeneratedDiscoverRepository: DiscoverRepositoryProtocol {
    let client: ScubaPalAPI.Client
    let mapper: DiscoveryMapper

    func learnArticles() async throws -> [LearnArticle] {
        let response = try await client.someGeneratedLearnOperation()
        return try response.body.items.map(mapper.map)
    }
}
```

The exact generated operation names should be confirmed after adding the package product to the app target and compiling generated symbols.

## Mapper Strategy

Keep mappers between API models and domain models even after generation:

- Generated models are transport contracts.
- Domain models are app contracts.
- SwiftUI should continue using domain models only.
- Mapper tests should remain the safety net when generated field names or optionality shift.

## Rollout Steps

1. Confirm the backend spec source of truth and sync process.
2. Add `ScubaPalAPI` package product to the iOS app target.
3. Create one generated-backed repository implementation for a low-risk read endpoint.
4. Keep the existing repository protocol unchanged.
5. Update `AppDependencies.live` to use the generated-backed implementation for that one slice.
6. Keep preview dependencies untouched.
7. Run mapper tests and simulator tests.
8. Repeat per feature area after each slice is stable.

## Guardrails

- Do not leak generated models into SwiftUI views.
- Do not delete hand-written DTOs until a whole feature has moved and tests cover the mapper behavior.
- Do not migrate auth first; token refresh behavior has more edge cases.
- Keep generated code in its package so regeneration does not churn app-layer files.
