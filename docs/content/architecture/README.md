---
title: "Architecture Docs Guide"
sidebar_label: "Docs Guide"
sidebar_position: 19
slug: /architecture/docs-guide
description: "How to place, navigate, and maintain the Scuba Pal Docusaurus architecture docs."
tags:
  - scuba-pal
  - docusaurus
  - docs
keywords:
  - "scuba-pal"
  - "docusaurus"
  - "docs"
---

# Architecture docs guide

These files belong under the Docusaurus docs content path.

```text
scuba-pal/
  docs/
    docusaurus.config.*
    content/
      architecture/
        _category_.json
        index.md
        01-product-brief.md
        02-glossary.md
        03-actor-map.md
        04-domain-model.md
        05-erd-data-truth.md
        06-state-machines.md
        07-use-case.md
        08-sequence.md
        09-api-tree.md
        10-event-catalog.md
        11-permission-matrix.md
        12-screen-map.md
        13-system-architecture.md
        14-deployment.md
        15-architecture-decision-records.md
```

## Docusaurus convention

If your Docusaurus project root is `docs`, and your docs plugin path is renamed from `docs` to `content`, then the docs plugin should point at `content`.

```js
// docusaurus.config.js
presets: [
  [
    'classic',
    {
      docs: {
        path: 'content',
        routeBasePath: 'docs',
        sidebarPath: './sidebars.js',
      },
    },
  ],
]
```

## Maintenance workflow

```mermaid
flowchart LR
    Change[Backend/API/Data Change] --> Docs[Update architecture doc]
    Docs --> Migration[Update Flyway migration if data changed]
    Docs --> OpenAPI[Update /v3/api-docs]
    OpenAPI --> Generate[Regenerate mobile client]
    Generate --> Mobile[Update mobile usage]
    Mobile --> Test[Run smoke tests]
```

## Checklist before committing docs

- Front matter exists on every Docusaurus page.
- `sidebar_position` creates a predictable reading order.
- `slug` is stable and does not depend on filename churn.
- Mermaid diagrams render locally.
- No template examples from unrelated domains remain.
- API docs and generated mobile client path are mentioned where relevant.
