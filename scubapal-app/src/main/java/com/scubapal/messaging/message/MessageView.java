package com.scubapal.messaging.message;

import java.time.LocalDateTime;

public record MessageView(
        Long messageId,
        Long senderUserId,
        String senderUsername,
        String senderProfileImageUrl,
        String messageText,
        LocalDateTime createdAt,
        LocalDateTime readAt,
        boolean sentByCurrentUser) {
}
