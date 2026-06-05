Treat ScubaPal iOS code as production application code.

- This is a native SwiftUI app. Prefer SwiftUI, Swift concurrency, Foundation, and small focused view components.
- The generated OpenAPI package lives at `Packages/ScubaPalAPI`; treat it as disposable generated code and do not hand-edit generated outputs.
- Keep backend/API access behind `Core/Networking/APIClient` and repository services. SwiftUI views should not call generated clients or `URLSession` directly.
- Keep app wiring in `App`, infrastructure in `Core`, reusable visual primitives in `DesignSystem`, feature code in `Features`, and app-facing models/mappers in `Domain` or mapper folders.
- Prefer feature folders shaped as view, store/view model, components, and feature-specific repository/service only when needed.
- Store auth/session secrets in Keychain-backed abstractions, never in `UserDefaults`.
- Do not commit secrets, API keys, local machine config, DerivedData, or per-user Xcode state.
- Run the safest available build/tests before the final answer and report any local tooling or simulator failures exactly.
