---
title: OpenAPI Generator
description: Generate client for mobile app
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