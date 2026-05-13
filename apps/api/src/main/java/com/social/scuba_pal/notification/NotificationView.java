package com.social.scuba_pal.notification;

import java.time.LocalDateTime;

public record NotificationView(
        Long notificationId,
        String title,
        String message,
        boolean read,
        LocalDateTime createdAt
) {}
