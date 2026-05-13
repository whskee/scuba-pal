package com.social.scuba_pal.messaging.message;

import java.time.LocalDateTime;

public record DirectMessageView(
                Long messageId,
                Long senderUserId,
                String senderUsername,
                String messageText,
                LocalDateTime createdAt,
                LocalDateTime readAt,
                boolean sentByCurrentUser) {
}
