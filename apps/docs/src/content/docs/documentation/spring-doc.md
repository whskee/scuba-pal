---
title: Spring Doc
description: A reference for documentation.
---

```bash
@Operation(summary = "Get user profile")
@GetMapping("/api/profile/{id}")
public ProfileResponse getProfile(@PathVariable Long id) {
    ...
}
```