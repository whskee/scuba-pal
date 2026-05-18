package com.scubapal.messaging.message;

public record UnreadCountView(
                long unreadMessageCount,
                long unreadNotificationCount) {
}
