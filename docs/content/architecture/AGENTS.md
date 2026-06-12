---
title: "Contributor Notes"
sidebar_label: "Contributor Notes"
sidebar_position: 20
slug: /architecture/contributor-notes
description: "Instructions for human and AI contributors updating Scuba Pal architecture docs."
unlisted: true
tags:
  - scuba-pal
  - docs
  - workflow
keywords:
  - "scuba-pal"
  - "docs"
  - "workflow"
---

# Contributor notes

These docs are the Scuba Pal architecture source of truth.

## Rules for updates

- Keep examples specific to Scuba Pal.
- Prefer stable architecture language over temporary implementation details.
- Update the API tree when backend controllers change.
- Regenerate the mobile client after OpenAPI changes.
- Update the ERD when Flyway migrations change schema shape.
- Add an ADR when a decision changes deployment, persistence, security, API contracts, or module boundaries.
- Do not leave unrelated template domains inside Scuba Pal docs.

## Repo truth

```text
scuba-pal/
  app/       # Java 25 Spring Boot backend + Thymeleaf
  mobile/    # React Native Expo mobile app
  docs/      # Docusaurus project
```
