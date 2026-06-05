# ScubaPal iOS — Codex Instructions

## Project Goal

ScubaPal iOS is a native SwiftUI client for the ScubaPal backend. The app should be production-quality, modular, maintainable, testable, and friendly to future OpenAPI client generation.

Prioritize long-term architecture over quick patches.

## Core Principles

1. Prefer small, safe, reviewable changes.
2. Do not do large rewrites unless explicitly requested.
3. Preserve current behavior unless the task says otherwise.
4. Avoid duplicate API contracts, magic strings, and repeated loading/error UI.
5. Keep dependency direction clean:
   - SwiftUI Views depend on ViewModels and DesignSystem.
   - ViewModels depend on repositories/protocols and domain models.
   - Repositories depend on APIClient, DTOs, and mappers.
   - Domain models do not depend on networking, SwiftUI, or DTOs.
6. Do not put live networking dependencies directly in previews.
7. Do not commit local config, machine-specific files, user state, secrets, or generated trash.

## Architecture Boundaries

Preferred top-level structure:

ScubaPal/
  App/
  Core/
  DesignSystem/
  Domain/
  API/
  Features/
  Resources/

Use:

- `App/` for app entry point, dependency composition, app state, routing.
- `Core/` for infrastructure: networking, auth/session, keychain, logging, utilities.
- `DesignSystem/` for theme, components, modifiers, reusable visual language.
- `Domain/` for app-level models and value types.
- `API/` for DTOs, endpoint definitions, mappers, generated API client code.
- `Features/` for vertical product areas: Auth, Feed, Discover, Messaging, Notifications, Profile, Shell.
- `Resources/` for assets, strings, localization, config resources.

Avoid using `Shared` as a junk drawer. If something is truly shared, place it in the correct architectural layer instead.

## Swift Conventions

- Prefer clear names over clever names.
- Use `URL` suffix only for real `URL` values.
- Use `Path`, `Key`, `Identifier`, or `String` suffixes for string-backed values.
- Avoid magic strings for API paths, enum values, notification types, visibility statuses, difficulty levels, and roles.
- Prefer domain enums over raw strings.
- Prefer `private(set)` for view model state.
- Avoid putting `withAnimation` in view models.
- View models should not import SwiftUI unless unavoidable.
- Put animation in views.
- Keep screen files mostly compositional.
- Extract reusable components when a view file exceeds roughly 200 lines or mixes unrelated concerns.
- Do not create protocols for every type. Create protocols mainly at dependency boundaries.

## Networking Rules

- Centralize endpoint paths.
- Centralize pagination query parameters.
- Keep DTOs separate from domain models.
- Use mappers between DTOs and domain models.
- Mapper behavior should be covered by tests.
- Do not leak DTOs into SwiftUI views.
- Do not leak APIClient directly into SwiftUI views.
- Prepare the app for future OpenAPI generation.
- If an OpenAPI spec exists, prefer generated DTO/client types over hand-maintained duplicate contracts.

## Dependency Injection

- App-level dependencies should be composed once in `AppDependencies`.
- Screens should receive repositories/view models through explicit injection or SwiftUI environment.
- Tests and previews must use mock/stub dependencies.
- Production dependencies should not be the default inside previews.

## Config and Repo Hygiene

Never commit:

- `.DS_Store`
- `__MACOSX/`
- `xcuserdata/`
- `*.xcuserstate`
- `Config/Debug.local.xcconfig`
- machine-specific hostnames
- secrets
- tokens
- API keys
- local-only build files

Keep:

- `Config/Debug.local.xcconfig.example`
- non-secret `.xcconfig` files
- documented setup steps

## Testing Expectations

When changing architecture, add or update tests where possible.

Prioritize tests for:

- mappers
- API path helpers
- pagination helpers
- repositories with mocked API clients
- view model state transitions
- auth/session behavior

## Build Safety

After changes, attempt the strongest available validation:

1. `swift test` if this is a Swift package.
2. `xcodebuild test` if Xcode project/scheme is available.
3. Static inspection if build tooling is unavailable.

Report what was run and what could not be run.

## Output Expectations

For every task:

1. Summarize the architectural intent.
2. List changed files.
3. Explain important tradeoffs.
4. Mention follow-up tasks.
5. Do not hide build/test failures.
