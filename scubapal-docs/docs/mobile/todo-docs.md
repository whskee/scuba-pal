---
title: Mobile Screenshots
description: Where to place screenshots in docs
tags: [todo]
---

Put **mobile screenshots in the docs site**, not inside `mobile/src`, because screenshots are documentation assets, not app source code.

Since your repo root is `scuba-pal/`, with backend in `app/` and React Native Expo in `mobile/`, keep the docs assets under the root documentation site. 

Recommended:

```text
scuba-pal/
├── app/
├── mobile/
├── docs/
│   ├── docs/
│   │   ├── mobile/
│   │   │   ├── overview.md
│   │   │   ├── screenshots.md
│   │   │   ├── navigation.md
│   │   │   └── api-client.md
│   │   └── architecture/
│   ├── static/
│   │   └── img/
│   │       ├── diagrams/
│   │       └── screenshots/
│   │           ├── mobile/
│   │           │   ├── feed.png
│   │           │   ├── login.png
│   │           │   ├── profile.png
│   │           │   ├── dive-map.png
│   │           │   └── messaging.png
│   │           └── web/
│   │               ├── feed.png
│   │               └── dive-locations.png
│   └── diagrams/
```

Use this convention:

```text
docs/static/img/screenshots/mobile/
```

Then reference them in docs like:

```md
![Mobile feed screen](/img/screenshots/mobile/feed.png)
```

For feature-specific screenshots, this is also clean:

```text
docs/static/img/screenshots/mobile/identity/login.png
docs/static/img/screenshots/mobile/social/feed.png
docs/static/img/screenshots/mobile/dive/dive-map.png
docs/static/img/screenshots/mobile/messaging/conversation.png
```

I would use that once screenshots grow:

```text
screenshots/
├── mobile/
│   ├── identity/
│   ├── social/
│   ├── dive/
│   ├── messaging/
│   └── profile/
└── web/
    ├── identity/
    ├── social/
    └── dive/
```

Keep **app-owned images** inside `mobile/assets/` only when the mobile app actually uses them at runtime:

```text
mobile/assets/
├── icons/
├── images/
└── splash/
```

Examples:

```text
mobile/assets/icon.png
mobile/assets/splash.png
mobile/assets/images/logo.png
```

But screenshots, mockups, diagrams, walkthrough images, and documentation visuals should go here:

```text
docs/static/img/
```

Clean rule:

```text
Used by the app at runtime?
→ mobile/assets/

Used to explain the app in docs?
→ docs/static/img/screenshots/mobile/

Editable diagram source?
→ docs/diagrams/

Rendered diagram image?
→ docs/static/img/diagrams/
```

Documentation progress: **30%**.

Next goal: create this first:

```text
docs/static/img/screenshots/mobile/
docs/docs/mobile/screenshots.md
```

Then add only 3 screenshots first: `login.png`, `feed.png`, and `dive-map.png`.
