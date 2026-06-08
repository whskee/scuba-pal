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
postgresql://localhost:5432/scubapal
postgresql://<username>:<password>@localhost:5432/<database_name>
postgresql://scubapal_runtime:scubapal@localhost:5432/scubapal
```
