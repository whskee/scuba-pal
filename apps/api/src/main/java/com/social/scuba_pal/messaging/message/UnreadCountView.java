package com.social.scuba_pal.messaging.message;

public record UnreadCountView(
                long unreadMessageCount,
                long unreadNotificationCount) {
}
