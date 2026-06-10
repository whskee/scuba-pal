---
title: Generated Scuba Pal Inventory
description: Deterministic project inventory generated from README, OpenAPI, Java source, and database metadata.
tags: [api, automation]
---

# Generated Scuba Pal Inventory

Scuba Pal is a community of scuba divers. A platform for connecting divers to dive deep, and connect deeper. Access developer documentation on GitHub Pages.

## Counts

| Area | Count |
| --- | ---: |
| controllers | 24 |
| databaseTables | 20 |
| entities | 22 |
| flywayMigrations | 14 |
| openapiEndpoints | 58 |
| openapiSchemas | 48 |
| repositories | 16 |
| services | 20 |

## README Features

- Main Feed: consists of ocean videos by users
- The app will allow users to connect with other Scuba Divers
- Find People to Dive with
- Find Dive Shops.
- Find Dive Locations
- Recommended PADI Certifications
- Users can log dives

## OpenAPI Tags

| Tag | Description |
| --- | --- |
| Admin User Management | Admin endpoints for managing user accounts |
| Authentication | Endpoints for user registration, login, and password management. |
| Current User | Endpoints for the authenticated user's account. |
| Dive Locations | Endpoints for discovering and creating dive locations |
| Dive Shops | Endpoints for discovering dive shops |
| Follows | Endpoints for follow actions and read-only follow lists |
| Learn | Endpoints for scuba education content |
| Media | Endpoints for requesting direct-to-S3 media uploads |
| Messaging | Endpoints for conversations and direct messaging |
| Notifications | Endpoints for listing and acknowledging notifications |
| Posts | Endpoints for creating, retrieving, updating, and deleting posts and comments |
| Profiles | Endpoints for creating and managing diver profiles |

## Database Tables

| Schema | Table |
| --- | --- |
| certification | certification_agencies |
| certification | certification_levels |
| certification | user_certifications |
| dive | dive_locations |
| dive | dive_shops |
| identity | flyway_schema_history |
| identity | password_reset_tokens |
| identity | profiles |
| identity | refresh_tokens |
| identity | roles |
| identity | users |
| learn | articles |
| messaging | conversations |
| messaging | messages |
| notification | notifications |
| social | post_comments |
| social | post_likes |
| social | post_media |
| social | posts |
| social | user_follows |
