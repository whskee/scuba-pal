# Migration Summary

This codebase was migrated from the older generated OpenAPI client to the newly generated TypeScript Axios client.

## Updated

- Replaced `src/api/generated` with the new generated client.
- Updated API wrappers to use generated clients instead of hardcoded Spring Boot `/api/...` strings.
- Migrated old generated API names:
  - `FollowControllerApi` -> `FollowsApi`
  - `ProfileControllerApi` -> `ProfilesApi`
  - `MessagingControllerApi` -> `MessagingApi`
  - `LocationControllerApi` -> `DiveLocationsApi` where applicable
- Migrated profile code from backend entity-shaped `Profile` to DTO-shaped `ProfileResponse` and `UpsertProfileRequest`.
- Migrated media upload presign request to generated `MediaApi.createUpload`.
- Kept direct `axios.put(uploadUrl, blob)` for S3/presigned uploads because that is not a Spring Boot API endpoint.
- Migrated learn, notification, messaging, social, profile, and feed wrappers to the new generated client.
- Removed raw Spring Boot endpoint calls from feature wrappers.
- Added `OPENAPI_CLIENT_WORKFLOW.md`.
- Added `.env.example`.
- Updated `Makefile` with `generate-api` and `typecheck` targets.
- Fixed env validation so localhost works for simulators.

## Verification

```bash
npm run typecheck
```

Passed after migration.

## Important backend cleanup for later

Generated methods like `markRead1` and `markRead2` should be fixed in the Spring Boot backend using explicit OpenAPI operation IDs. Do not manually rename generated mobile methods.
