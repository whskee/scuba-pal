---
title: Mailing
description: Guide to setup Mailpit.
tags: [service, app, tool, docker]
---

# Mailpit setup

```docker
services:
  mailpit:
    image: axllent/mailpit:latest
    container_name: mailpit
    restart: unless-stopped
    ports:
      - "8025:8025" # Web UI
      - "1025:1025" # SMTP server
    volumes:
      - ./mailpit-data:/data
    environment:
      - MP_DATABASE=/data/mailpit.db
      - TZ=America/Chicago # Optional: Set your timezone
```
