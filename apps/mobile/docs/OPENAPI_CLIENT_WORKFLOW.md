# OpenAPI Client Workflow

The backend OpenAPI contract is the source of truth for backend/mobile communication.

## Rules

- Do not edit `src/api/generated/*` manually.
- Keep app-specific behavior in feature API wrappers under `src/features/**/**Api.ts`.
- Screens should call feature wrappers, not generated clients directly.
- Raw Axios calls to Spring Boot endpoints should be avoided when the endpoint exists in the generated client.
- Direct S3/presigned upload calls are allowed because those URLs are not Spring Boot API endpoints.

## Regenerate after backend contract changes

Regenerate when a Spring controller route, request DTO, response DTO, enum, path variable, query parameter, or OpenAPI annotation changes.

```bash
make generate-api
make typecheck
```

If generation causes ugly method names like `markRead1` or `markRead2`, fix the backend with explicit `@Operation(operationId = "...")` values and regenerate. Do not rename generated methods in mobile code.

## Mobile wrapper shape

```txt
Screen -> feature API wrapper -> generated OpenAPI client -> configured Axios instance -> Spring Boot
```

Current wrapper files:

```txt
src/features/auth/authApi.ts
src/features/feed/feedApi.ts
src/features/profile/profileApi.ts
src/features/social/socialApi.ts
src/features/messaging/messagesApi.ts
src/features/notifications/notificationsApi.ts
src/features/media/mediaApi.ts
src/features/learn/learnApi.ts
src/features/search/usersApi.ts
```
