# Scuba Pal Native

Expo React Native client for the Scuba Pal Spring Boot backend.

## What is wired

- The generated OpenAPI `typescript-axios` client lives in `src/api/generated`.
- App code should not import generated classes directly from screens.
- Screens call feature wrappers instead:
  - `src/features/auth/authApi.ts`
  - `src/features/feed/feedApi.ts`
  - `src/features/profile/profileApi.ts`
  - `src/features/messaging/messagesApi.ts`
  - `src/features/notifications/notificationsApi.ts`
- Shared Axios configuration, base URL, auth header, and error handling live in `src/services/api.ts`.

## Backend URL

The app uses the backend root URL, not `/api`:

```bash
EXPO_PUBLIC_API_BASE_URL=http://localhost:8080
```

Use the right value for your target:

- iOS simulator: `http://localhost:8080`
- Android emulator: `http://10.0.2.2:8080`
- Physical phone: `http://YOUR_MAC_LAN_IP:8080`

For physical devices, Spring Boot should be reachable from your LAN and not blocked by your Mac firewall.

## Regenerate the API client

Run this from the native repo while the backend is running:

```bash
curl http://localhost:8080/v3/api-docs -o openapi.json
rm -rf src/api/generated
openapi-generator generate \
  -i ./openapi.json \
  -g typescript-axios \
  -o ./src/api/generated
rm -f src/api/generated/git_push.sh
```

Then keep your app code in the wrapper files. Do not manually edit files inside `src/api/generated`.

## Backend gaps currently handled gracefully

The provided OpenAPI contract currently does not expose these mobile-friendly endpoints:

- conversation list
- send message
- notifications list
- mark notification read
- unread notification count
- read-only followers/following list

The Expo app now avoids crashing for those missing contracts, but the backend should add those endpoints for full native functionality.



# Get IP Address
```bash
ipconfig getifaddr en0
```