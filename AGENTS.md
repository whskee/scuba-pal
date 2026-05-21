# Agent Operating Notes

Use this repo as a productized RT Social Discovery app, not a generic app factory.

## Backend standards

- Keep controllers thin.
- Use Lombok.
- Return DTOs only; never return JPA entities.
- Put domain logic in services.
- Keep database names snake_case and API names camelCase.
- Add Flyway migrations for every schema change.
- Prefer explicit validation over implicit assumptions.
- Treat all write endpoints as authenticated unless intentionally public.

## Frontend standards

- Keep generated API code isolated in `src/generated/api`.
- The UI feel should be premium, classy, hard to take your eyes off.
- Product UI should feel immediate: optimistic actions, live pulse, clear empty states.
- Keep SEO route/file names lowercase and descriptive.

## Deployment standards

- Secrets only through environment variables.
- No demo credentials committed.
- CORS origins must be explicit in production.
