# Scuba Pal Mobile Expo

Expo React Native client for the Scuba Pal Spring Boot backend.

## Architecture

The generated OpenAPI `typescript-axios` client lives in `src/api/generated`.

Do not manually edit generated files. App code should use wrapper files instead:

- `src/features/auth/authApi.ts`
- `src/features/feed/feedApi.ts`
- `src/features/profile/profileApi.ts`
- `src/features/social/socialApi.ts`
- `src/features/messaging/messagesApi.ts`
- `src/features/notifications/notificationsApi.ts`
- `src/features/media/mediaApi.ts`
- `src/features/learn/learnApi.ts`
- `src/features/search/usersApi.ts`

Shared Axios configuration, base URL, auth header, timeout, and error normalization live in `src/services/api.ts`.

## Backend URL

Create `.env.local` from `.env.example`:

```bash
cp .env.example .env.local
```

The app uses the backend root URL, not `/api`:

```bash
EXPO_PUBLIC_API_BASE_URL=http://localhost:8080
```

Use the right value for your target:

- iOS simulator: `http://localhost:8080`
- Android emulator: `http://10.0.2.2:8080`
- Physical phone: `http://YOUR_MAC_LAN_IP:8080`

For physical devices, Spring Boot must be reachable from your LAN and your firewall must allow port `8080`.

## Regenerate the API client

Run this from the mobile repo while the backend is running:

```bash
make generate-api
make typecheck
```

The generation target is `src/api/generated`.

## Development commands

```bash
make install
make dev
make ios
make android
make typecheck
```

## Get your Mac LAN IP

```bash
ipconfig getifaddr en0
```

Use that IP for physical Expo Go devices.
