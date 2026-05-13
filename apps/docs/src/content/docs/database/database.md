---
title: Flyway Migrations
description: A reference page in my new Starlight docs site.
---

## Demo access

Seeded users are created through Flyway:

- `admin` / `admin123` has the `admin` role.
- `maya_dives` / `password` has the default `user` role.

The app uses PostgreSQL schemas (`identity`, `social`, `dive`, `certification`, `notification`) and validates mappings with Hibernate.


## Database
- Schema migration: `src/main/resources/db/migration/V1__init_schema.sql`
- Mock data seed: `src/main/resources/db/migration/V2__seed_data.sql`

> [!IMPORTANT]
> - Security is currently open for MVP/demo speed.
> - Replace plaintext password handling with BCrypt/JWT before production.