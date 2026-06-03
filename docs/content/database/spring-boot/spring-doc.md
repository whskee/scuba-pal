---
title: Spring Doc
description: A reference for documentation.
tags: [spring, documentation]
---

```java
@Operation(summary = "Get user profile")
@GetMapping("/api/profile/{id}")
public ProfileResponse getProfile(@PathVariable Long id) {
    ...
}
```
