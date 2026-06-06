You are working inside my native iOS repository: scubapal-ios.

Goal:
Refactor and harden the ScubaPal iOS app architecture so it becomes production-style, maintainable, modular, and easy to understand without doing a risky rewrite. Preserve existing behavior unless there is an obvious bug. Prefer small, safe, incremental changes over large rewrites.

Context:
ScubaPal is a social + utility app for divers. The backend is a Spring Boot API. The iOS app is native SwiftUI. The backend OpenAPI spec is used to generate a local Swift API package at:

Packages/ScubaPalAPI

The generated API package should be treated as disposable/generated code. Do not hand-edit generated files unless absolutely necessary and clearly explain why. Application code should depend on generated API types through a clean wrapper layer, not directly from SwiftUI views.

Primary architecture target:

App
= app entry point, dependency wiring, root routing, main tab shell

Core
= networking, API client wrapper, auth/session/token storage, app config, errors, persistence/system utilities

DesignSystem
= colors, typography, spacing, reusable components, reusable modifiers

Features
= user-facing modules such as Auth, Feed, Discover, Messaging, Profile, DiveLocations

Shared
= domain models, DTO adapters, mappers, reusable non-visual helpers

Packages/ScubaPalAPI
= generated OpenAPI Swift client package

Tests
= unit tests for mappers, stores/view models, API error mapping, auth/token behavior

Hard rules:
1. Do not do a massive rewrite.
2. Do not delete behavior unless it is clearly dead code and you explain it.
3. Do not hand-edit generated OpenAPI files.
4. Do not put networking logic directly in SwiftUI views.
5. Do not put styling constants directly throughout feature views if they belong in DesignSystem.
6. Do not store auth tokens in UserDefaults.
7. Do not introduce unnecessary third-party dependencies.
8. Prefer native SwiftUI, Swift concurrency, and Foundation.
9. Keep names clean: user-facing app/product should be ScubaPal, repo/folder may remain scubapal-ios, bundle id should be com.scubapal.app unless the project already intentionally uses a different value.
10. Keep changes compile-safe. Run validation commands before finishing.
11. If an Xcode project setting must change, make the smallest safe edit and explain it.
12. If something is ambiguous, inspect the project and make the best conservative decision instead of asking me.

First, inspect the repository:
- Print a concise directory overview.
- Identify the app target name, schemes, bundle identifier, deployment targets, Swift version, and package dependencies.
- Identify large Swift files, especially large SwiftUI views.
- Identify whether views directly call generated API clients or URLSession.
- Identify whether there is already an APIClient, AuthStore, SessionStore, TokenStore, AppConfig, or AppEnvironment.
- Identify duplicate assets such as extra AppIcon sets.
- Identify config files such as Debug.xcconfig, Release.xcconfig, Staging.xcconfig, Debug.local.xcconfig.
- Identify available tests and current test/build status.

Expected final architecture direction:

Use this dependency flow:

SwiftUI View
→ Feature Store/ViewModel
→ Core Service/APIClient
→ Generated ScubaPalAPI client
→ Backend

Generated response DTO/API type
→ Mapper
→ Domain model
→ Store/ViewModel state
→ SwiftUI View

Do not let this happen:

SwiftUI View
→ Generated ScubaPalAPI client directly

or:

SwiftUI View
→ URLSession directly

Refactor priorities:

PHASE 1 — Safety and project hygiene
1. Create or update AGENTS.md at the repository root with concise project rules:
   - Native SwiftUI app.
   - Generated OpenAPI package is under Packages/ScubaPalAPI.
   - Do not hand-edit generated files.
   - Keep generated API behind Core/APIClient.
   - Prefer feature folders.
   - Prefer small SwiftUI components.
   - Run build/tests before final answer.
   - Do not commit secrets or local machine config.
2. Check .gitignore and ensure local/private files are ignored:
   - DerivedData
   - .build
   - xcuserdata
   - Debug.local.xcconfig if it contains machine-specific values
   - secrets, .env, API keys
3. Inspect Assets.xcassets and remove or flag duplicate app icon sets such as "AppIcon 1" if safely removable.
4. Verify Product Name, target/module name, and bundle identifier conventions:
   - Product/display name: ScubaPal
   - Repository/folder: scubapal-ios
   - Bundle identifier: com.scubapal.app for production
   - Development/staging variants may use com.scubapal.app.dev and com.scubapal.app.staging
5. Do not break signing. If changing bundle id/signing is risky, document the recommended change instead of applying it.

PHASE 2 — App composition cleanup
1. Ensure there is a clear App layer:
   - ScubaPalApp.swift
   - AppRootView.swift
   - AppEnvironment.swift or equivalent dependency container
   - MainTabView.swift or equivalent shell
2. The @main App type should be minimal.
3. AppRootView should decide between authentication flow and main app using auth/session state.
4. MainTabView should only define navigation tabs, not contain feature business logic.
5. Dependency creation should happen centrally, not scattered across screens.

PHASE 3 — Core networking/API boundary
1. Find existing APIClient or create one if missing.
2. APIClient should be the single clean boundary around the generated ScubaPalAPI package.
3. Prefer actor or Sendable-safe design if appropriate.
4. APIClient responsibilities:
   - own generated client setup
   - use base URL from AppConfig
   - attach auth tokens if existing token infrastructure exists
   - map transport/generated errors into app-level errors
   - expose clean async functions used by feature stores
5. Do not expose generated API details to SwiftUI views.
6. If generated API types are currently used directly in views, move that usage into stores/services/mappers.
7. Keep generated API package untouched.

PHASE 4 — App configuration
1. Centralize environment config:
   - API base URL
   - app environment name
   - feature flags if already present
2. Prefer xcconfig-backed values or Info.plist expansion if that is already the project pattern.
3. Remove hardcoded localhost/backend URLs from feature views and random files.
4. Debug.local.xcconfig should be local-only if it contains personal machine values.
5. If Staging.xcconfig exists but is not wired into an Xcode build configuration, either wire it safely or document the exact recommended Xcode setup.

PHASE 5 — Auth/session/token storage
1. Inspect current auth flow.
2. Ensure login/register screens talk to an AuthStore/AuthService, not directly to generated client code.
3. Ensure auth/session state is centralized.
4. Ensure tokens are stored in Keychain or a KeychainTokenStore abstraction.
5. Do not use UserDefaults for secrets.
6. Add a minimal AppSession model if useful.
7. Make the app root respond clearly to logged-in/logged-out state.

PHASE 6 — Feature folder cleanup
For each major feature, enforce this shape when practical:

```
Features/<FeatureName>/
├── <FeatureName>View.swift
├── <FeatureName>Store.swift or <FeatureName>ViewModel.swift
├── Components/
├── Models/ if feature-local models are needed
└── Services/ only if the service is truly feature-specific
```

Features to inspect:
- Auth
- Feed
- Discover
- Messaging
- Profile
- DiveLocations if present
- Settings if present

Specific large-view refactor goal:
If files like FeedView.swift, ProfileView.swift, DiscoverView.swift, or MessagingView.swift are large, split them into named components.

Examples:
FeedView.swift should not contain every post/card/header/loading/error view inline.
Create components such as:
- FeedHeaderView
- PostCardView
- FeedEmptyStateView
- FeedLoadingView
- FeedErrorView
- CreatePostButton or Composer entry point if present

ProfileView.swift may become:
- ProfileHeaderView
- ProfileStatsRow
- ProfileBioSection
- ProfileActionButtons
- ProfilePostGrid

DiscoverView.swift may become:
- DiscoverSearchBar
- DiveLocationCard
- DiverSuggestionCard
- CategoryChip
- DiscoverSectionHeader

MessagingView.swift may become:
- ConversationRow
- MessageBubble
- MessageInputBar
- ConversationListView
- ConversationDetailView

Important:
Only extract components where it improves clarity. Do not create tiny pointless files.

PHASE 7 — DesignSystem cleanup
1. Inspect existing DesignSystem.
2. Ensure reusable visual primitives exist:
   - colors/theme
   - typography
   - spacing
   - cards
   - buttons
   - avatars
   - loading indicators
   - empty/error states
3. Replace repeated styling in feature views with reusable design components where obvious.
4. Do not over-abstract everything. Focus on repeated patterns.
5. Keep the app looking the same or better.
6. Avoid global styling hacks.

PHASE 8 — DTO/domain/mapping boundary
1. Inspect Shared/DTO, Shared/Domain, Shared/Mappers or equivalent.
2. Ensure backend/generated response shapes are converted into clean app domain models.
3. Add mapper functions where views currently massage generated API types directly.
4. Add small tests for important mappers.
5. Keep domain models stable and app-centric.
6. Generated API models should not leak into UI unless there is a very good reason.

PHASE 9 — Error/loading/empty states
1. Standardize feature state where practical:
   - idle
   - loading
   - loaded
   - empty
   - failed
2. Use reusable error/empty/loading views from DesignSystem where appropriate.
3. Do not leave silent failures.
4. User-facing errors should be clear but not overly technical.
5. Internal errors should remain useful in debug logs.

PHASE 10 — Tests
Add or improve tests where feasible:
1. Mapper tests.
2. API error mapping tests.
3. Auth/token storage tests if possible without real Keychain complexity.
4. Store/ViewModel state transition tests for at least one feature, preferably Feed or Auth.
5. Avoid brittle UI tests unless already established.

PHASE 11 — Build/package validation
Before finishing, discover the correct schemes and run the safest available validation commands.

Suggested discovery commands:
- xcodebuild -list
- xcrun simctl list devices available
- swift test --package-path Packages/ScubaPalAPI if the package has tests
- swift build --package-path Packages/ScubaPalAPI if applicable

Then run an iOS build using the actual discovered scheme and an available simulator destination.

If a command fails because of local signing/simulator/toolchain environment, report:
- exact command run
- exact failure
- whether code changes are still logically safe
- what I should run locally

Acceptance criteria:
1. App still builds or failures are clearly environmental.
2. Generated ScubaPalAPI code is not manually edited.
3. SwiftUI views are smaller and more readable.
4. Feature logic is moved into stores/view models where appropriate.
5. API access is behind Core/APIClient.
6. Auth/session handling is centralized or clearly improved.
7. Styling duplication is reduced through DesignSystem.
8. DTO/domain/mapper boundaries are clearer.
9. Local/private config is not committed.
10. AGENTS.md exists with project rules.
11. Final response includes:
    - summary of changes
    - files changed
    - architecture before/after
    - tests/build commands run
    - remaining recommended follow-ups

Output style:
Be direct and specific. Do not give vague advice. Make the code changes. If you intentionally skip something, explain why.

Important implementation preferences:
- Prefer convention over configuration.
- Prefer simple native Swift/SwiftUI over clever abstractions.
- Prefer clear names over short names.
- Prefer composition over inheritance.
- Prefer small files with meaningful names.
- Prefer one obvious way to do something.
- Do not add unnecessary protocols unless needed for testing or dependency inversion.
- Do not create fake abstraction layers just to look architectural.
- Do not over-modularize into Swift packages yet unless the project already uses that pattern.
- Keep Core and DesignSystem stable.
- Keep feature modules understandable.

Specific naming conventions:
- App display/product/module name should be ScubaPal where practical.
- Repo/folder name may remain scubapal-ios.
- Bundle id should be com.scubapal.app for production unless already intentionally different.
- Generated package remains ScubaPalAPI.
- Feature stores should be named like FeedStore, ProfileStore, AuthStore.
- Components should be named by UI role, such as PostCardView, ProfileHeaderView, MessageBubbleView.
- Domain models should be clean names like Post, UserProfile, Conversation, Message, DiveLocation.
- DTO/generated names should not drive UI names.

Useful final architecture diagram to keep in mind:

User Action
→ SwiftUI Feature View
→ Feature Store/ViewModel
→ Core Service/APIClient
→ Generated ScubaPalAPI Client
→ Spring Boot Backend
→ Generated Response
→ Mapper
→ Domain Model
→ Store State
→ SwiftUI Render

Now inspect the repository and execute this refactor safely.
