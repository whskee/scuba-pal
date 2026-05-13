# Scuba Pal testing guide

These tests are fast unit/controller tests for the app areas that keep changing: auth, feed pagination, like/unlike, follow/unfollow, notifications, messaging, read receipts, profile access, and post visibility.

## Run all tests

From your project root, run whichever command matches your project:

```bash
./mvnw test
```

If you do not have the Maven wrapper:

```bash
mvn test
```

If your project is Gradle instead:

```bash
./gradlew test
```

## Run one test class

Maven:

```bash
./mvnw -Dtest=PostServiceTest test
./mvnw -Dtest=MessagingServiceTest test
./mvnw -Dtest=FollowServiceTest test
```

Gradle:

```bash
./gradlew test --tests "com.social.scuba_pal.social.post.PostServiceTest"
./gradlew test --tests "com.social.scuba_pal.messaging.MessagingServiceTest"
./gradlew test --tests "com.social.scuba_pal.social.follow.FollowServiceTest"
```

## Run one exact test method

Maven:

```bash
./mvnw -Dtest=MessagingServiceTest#sendMessageTrimsTextSavesMessageAndNotifiesReceiver test
```

Gradle:

```bash
./gradlew test --tests "com.social.scuba_pal.messaging.MessagingServiceTest.sendMessageTrimsTextSavesMessageAndNotifiesReceiver"
```

## What was added

| Area | Test file | What it checks |
|---|---|---|
| Auth | `AuthControllerTest` | register returns `201 Created`, login calls Spring Security authentication first, username availability delegates correctly |
| Feed pagination | `PostControllerTest` | page cannot go below `0`, size is capped at `50`, feed sorts newest-first |
| Like/unlike without refresh | `PostControllerTest`, `PostServiceTest` | `/api/posts/{id}/like` returns updated JSON detail instead of redirect/page refresh behavior; service creates/deletes likes |
| Follow/unfollow | `FollowServiceTest` | follow creates relationship + notification, follow is idempotent, unfollow deletes existing relationship |
| Notifications | `NotificationServiceTest` | paginated notifications, unread count, mark-all-read, create unread notification |
| Messaging | `MessagingServiceTest` | message text is trimmed, saved, and receiver gets notification |
| Read receipts | `MessagingServiceTest` | opening messages marks incoming messages read and maps `readAt` back to the view |
| Profile access | `ProfileServiceTest` | profile lookup, create defaults, update behavior |
| Post visibility | `PostServiceTest` | public feed asks repository for only `VisibilityStatus.PUBLIC` posts |

## Debugging common failures

If `ScubaPalApplicationTests.contextLoads()` fails but the unit tests pass, the issue is probably Spring context configuration, H2 dependency/config, Flyway, or schema creation — not these feature tests.

If Mockito tests fail with `UnnecessaryStubbingException`, remove the stub mentioned in the error. That usually means the tested method no longer uses that repository call.
