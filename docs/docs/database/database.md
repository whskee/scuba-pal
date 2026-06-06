---
title: Start Here
sidebar_label: Overview
description: A reference page in my new Starlight docs site.
tags: [todo]
---

# Start Here


We chose PostgreSQL as our database. The following table describes the database

| Domain     | Framework                             |
| ---------- | ------------------------------------- |
| ORM        | Spring Data JPA                       |
| Migrations | Flyway                                |
| Cloud      | [AWS RDS](https://aws.amazon.com/rds) |
| Storage    | [AWS S3](https://aws.amazon.com/s3)   |
| Tools      | pgAdmin, DataGrip                     |


## Flyway

Seeded users are created through Flyway:

- `admin` / `admin123` has the `admin` role.
- `maya_dives` / `password` has the default `user` role.

The app uses PostgreSQL schemas (`identity`, `social`, `dive`, `certification`, `notification`) and validates mappings with Hibernate.


## Database
- Schema migration: `src/main/resources/db/migration/V1__init_schema.sql`
- Mock data seed: `src/main/resources/db/migration/V2__seed_data.sql`

:::warning
- Security is currently open for MVP/demo speed.
- Replace plaintext password handling with BCrypt/JWT before production.
:::

## Resources
1. [Expert Tips on Database Naming Conventions](https://www.claravine.com/database-naming-conventions/)
2. [Database Design Basics](https://support.microsoft.com/en-US/Access/database-design-basics)
