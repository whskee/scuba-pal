---
title: DBML
description: A source of truth for database schemas
---

# Generate DBML
in vscode, once you get Docker up and running, `Cmd + Shift + P` and dbml, generate dbml for database connection.


from `apps/api/src/main/resources/application.properties`:

username and password are in `compose.yaml`

`postgresql://localhost:5432/scubapal`

`postgresql://<username>:<password>@localhost:5432/scubapal`
`postgresql://scubapal:scubapal@localhost:5432/scubapal`