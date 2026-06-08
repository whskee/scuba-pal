---
title: DBML
description: A source of truth for database schemas
tags: [database, lesson]
---

# Generate DBML
in vscode, once you get Docker up and running, `Cmd + Shift + P` and dbml, generate dbml for database connection.


from `apps/api/src/main/resources/application.properties`:

username and password are in `.env`

```
postgresql://localhost:5432/scuba_pal
postgresql://<username>:<password>@localhost:5432/<database_name>
postgresql://scuba_pal_runtime:scuba_pal@localhost:5432/scuba_pal
```
