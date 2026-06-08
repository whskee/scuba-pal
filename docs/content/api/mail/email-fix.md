---
title: Mailpit Fix
description: What codex fixed
tags: [todo, database, chatgpt, app]
---

Fixed it. The dev profile was configured for Mailpit, but `SmtpEmailService` was being skipped because it used `@ConditionalOnBean(JavaMailSender.class)` on a regular service. That let the dev console fallback take over.

Changes made:
- SMTP now activates whenever `app.mail.enabled=true`: [SmtpEmailService.java](/Users/cbidkar/Developer/active/scuba-pal/scubapal-app/src/main/java/com/scubapal/shared/mail/SmtpEmailService.java:16)
- Console fallback only activates in dev/test when mail is disabled or omitted: [ConsoleFallbackEmailService.java](/Users/cbidkar/Developer/active/scuba-pal/scubapal-app/src/main/java/com/scubapal/shared/mail/ConsoleFallbackEmailService.java:12)
- Dev mail config now honors `SMTP_HOST`, `SMTP_PORT`, and `APP_MAIL_FROM`, defaulting to Mailpit: [application-dev.properties](/Users/cbidkar/Developer/active/scuba-pal/scubapal-app/src/main/resources/application-dev.properties:8)
- Reset links now honor `APP_BASE_URL`: [application.properties](/Users/cbidkar/Developer/active/scuba-pal/scubapal-app/src/main/resources/application.properties:13)
- Added a context test proving dev uses SMTP when enabled: [EmailServiceSelectionTest.java](/Users/cbidkar/Developer/active/scuba-pal/scubapal-app/src/test/java/com/scubapal/shared/mail/EmailServiceSelectionTest.java:13)

Verified with `./mvnw test`: 45 tests passed.

Restart the app with the dev profile and make sure Mailpit is running on SMTP `1025`; password reset emails should show up in [Mailpit](http://localhost:8025). If you run the Java app inside Docker, set `SMTP_HOST=host.docker.internal` or the Mailpit service name, since `localhost` would point inside the app container.
