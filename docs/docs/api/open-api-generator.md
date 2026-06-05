---
title: OpenAPI Generator
description: Generate client for mobile app
tags: [api, tool]
---

## Generate mobile app client using React Native - Expo
> [!NOTE]
> You have to first run the Maven app

```bash
openapi-generator generate \
  -i http://localhost:8080/v3/api-docs \
  -g typescript-axios \
  -o ./generated-api
```
```bash
openapi-generator-cli generate \
  -i http://localhost:8080/v3/api-docs \
  -g typescript-fetch \
  -o mobile/api
```

# New recommended version

```bash
cd scuba-pal-mobile-expo

npm install axios
npm install -D @openapitools/openapi-generator-cli

npx openapi-generator-cli generate \
  -i http://localhost:8080/v3/api-docs \
  -g typescript-axios \
  -o src/api/generated \
  --additional-properties=supportsES6=true,useSingleRequestParameter=true,stringEnums=true
```

## Modified

```bash
cd apps/mobile

npm install axios
npm install -D @openapitools/openapi-generator-cli

npx openapi-generator-cli generate \
  -i http://localhost:8080/v3/api-docs \
  -g typescript-axios \
  -o src/api/generated \
  --additional-properties=supportsES6=true,useSingleRequestParameter=true,stringEnums=true
```

