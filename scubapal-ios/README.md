# Scuba Pal iOS

## API configuration

Debug builds use `http://127.0.0.1:8080` by default. That reaches a backend
running on the same Mac when using an iOS Simulator, but it cannot reach the Mac
from a physical iPhone.

For physical-device testing:

1. Copy `Config/Debug.local.xcconfig.example` to
   `Config/Debug.local.xcconfig`.
2. Replace `your-mac.local` with the Mac's local hostname from
   `hostname`.
3. Run the backend on port `8080`.
4. Connect the iPhone and Mac to the same local network.
5. Accept the local-network permission prompt when Scuba Pal first connects.

`Debug.local.xcconfig` is ignored by Git because it is specific to each
developer's network. Staging and Release builds should use HTTPS API endpoints
through `SCUBAPAL_STAGING_API_BASE_URL` and
`SCUBAPAL_PRODUCTION_API_BASE_URL`.
