# Logging and Error Handling

ScubaPal logs diagnostic failures through `AppLogger`, which wraps Apple's `OSLog.Logger`.

## Categories

- `networking`: API request, response, decoding, and token-refresh failures.
- `auth`: sign-in, registration, logout, and saved-session restore failures.
- `repository`: repository or mapper failures when useful outside the API client.
- `ui`: presentation-level diagnostics only.

## Safety Rules

- Never log auth tokens, passwords, raw request bodies, cookies, or sensitive headers.
- API logs may include HTTP method, endpoint path, status code, and redacted error diagnostics.
- Query values, request bodies, and authorization headers should stay out of logs by default.
- User-facing errors must use `error.userFacingMessage`, not raw backend messages.
- Backend messages can be useful diagnostics, but they must pass through `AppLogRedactor` before logging.

Generated API clients should follow the same convention: repositories wrap generated calls, log safe diagnostics, map generated models into domain models, and return clean user-facing errors to SwiftUI.
