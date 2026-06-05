# OpenAPI Client

ScubaPal has a generated Swift OpenAPI client package, but app behavior still runs through the existing handwritten `APIClient`, DTOs, mappers, and repositories. Do not migrate endpoints casually.

## Files

- Source OpenAPI file: `OpenAPI/scubapal-openapi.json`
- Package OpenAPI file: `Packages/ScubaPalAPI/Sources/ScubaPalAPI/openapi.json`
- Generated package: `Packages/ScubaPalAPI`

## Refresh Workflow

Refresh the backend OpenAPI spec from a local backend:

```sh
curl -fSL http://localhost:8080/v3/api-docs -o OpenAPI/scubapal-openapi.json
```

Copy it into the generated package:

```sh
cp OpenAPI/scubapal-openapi.json Packages/ScubaPalAPI/Sources/ScubaPalAPI/openapi.json
```

Validate/build the package:

```sh
swift build --package-path Packages/ScubaPalAPI
```

## Dependency Direction

`SwiftUI View -> ViewModel/Store -> Repository -> API Client -> Generated ScubaPalAPI -> Backend`

Generated API models must not leak into SwiftUI views. Repositories should map generated API models into app domain models before data reaches stores/view models.

When endpoint migration starts, do not migrate auth first. Prefer a read-only endpoint such as Learn or Dive Locations.
