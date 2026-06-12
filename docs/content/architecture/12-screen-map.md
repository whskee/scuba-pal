---
title: "Screen Map"
sidebar_label: "Screen Map"
sidebar_position: 13
slug: /architecture/screen-map
description: "Web and mobile screen map derived from Scuba Pal use cases."
tags:
  - scuba-pal
  - screens
  - frontend
keywords:
  - "scuba-pal"
  - "screens"
  - "frontend"
---

# Screen map

Frontend screens should be derived from use cases and the API tree.

```mermaid
flowchart TD
    Home[Home]
    Login[Login]
    Register[Register]
    ForgotPassword[Forgot Password]
    Feed[Feed]
    Profile[Profile]
    EditProfile[Edit Profile]
    CreatePost[Create Post]
    PostDetail[Post Detail]
    UserProfile[User Profile]
    DiveLocations[Dive Locations]
    DiveLocationDetail[Dive Location Detail]
    DiveShops[Dive Shops]
    DiveShopDetail[Dive Shop Detail]
    Conversations[Conversations]
    ConversationDetail[Conversation Detail]
    Notifications[Notifications]
    Learn[Learn]
    LearnArticle[Learn Article]
    AdminDashboard[Admin Dashboard]
    AdminUsers[Admin Users]
    AdminContent[Admin Content]

    Home --> Login
    Home --> Register
    Login --> ForgotPassword
    Login --> Feed
    Register --> EditProfile
    Feed --> CreatePost
    Feed --> PostDetail
    Feed --> Profile
    Feed --> UserProfile
    UserProfile --> Profile
    Profile --> EditProfile
    Feed --> DiveLocations
    DiveLocations --> DiveLocationDetail
    Feed --> DiveShops
    DiveShops --> DiveShopDetail
    Feed --> Conversations
    Conversations --> ConversationDetail
    Feed --> Notifications
    Feed --> Learn
    Learn --> LearnArticle
    AdminDashboard --> AdminUsers
    AdminDashboard --> AdminContent
```

## Web routes

| Screen | Example route | Primary APIs |
| --- | --- | --- |
| Home | `/` | Public content |
| Login | `/login` | `/api/auth/login` |
| Register | `/register` | `/api/auth/register` |
| Feed | `/feed` | `/api/feed`, `/api/posts` |
| Profile | `/profile` | `/api/profiles/me` |
| User Profile | `/users/{id}` | `/api/users/{id}`, `/api/profiles/{id}` |
| Dive Locations | `/dive-locations` | `/api/dive-locations` |
| Dive Shops | `/dive-shops` | `/api/dive-shops` |
| Conversations | `/messages` | `/api/conversations` |
| Notifications | `/notifications` | `/api/notifications` |
| Learn | `/learn` | `/api/learn/articles` |
| Admin | `/admin` | `/api/admin/stats` |

## Mobile navigation groups

| Group | Screens |
| --- | --- |
| Auth stack | Login, Register, Forgot Password |
| Main tabs | Feed, Dive, Learn, Messages, Profile |
| Modal flows | Create Post, Edit Profile, Media Upload |
| Detail flows | Post Detail, User Profile, Dive Location Detail, Conversation Detail |
| Admin stack | Admin Dashboard, Users, Content |
