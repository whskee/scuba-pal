Treat ScubaPal iOS code as production application code.

- ScubaPal iOS is a native SwiftUI client for the ScubaPal Spring Boot backend.
- Prefer small, reviewable, production-safe changes. Preserve behavior unless explicitly asked otherwise, and do not combine unrelated refactors.
- Generated OpenAPI package: `Packages/ScubaPalAPI`. Do not hand-edit generated OpenAPI files or expose generated models to SwiftUI.
- SwiftUI views must not import `ScubaPalAPI`; views depend on view models/stores, domain models, and `DesignSystem`.
- View models/stores depend on repositories and domain models.
- Repositories may call the handwritten `APIClient` or generated `ScubaPalAPI` client, but must map transport/API models into app domain models.
- Auth tokens stay in Keychain, never `UserDefaults`.
- Previews/tests must not use live networking by default.
- Do not commit secrets, local config, `xcuserdata`, `.DS_Store`, `__MACOSX`, DerivedData, or machine-specific files.
- Run the strongest available validation after code changes and report exact commands/results.
