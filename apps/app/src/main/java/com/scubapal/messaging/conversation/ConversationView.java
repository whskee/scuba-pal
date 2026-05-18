package com.scubapal.messaging.conversation;

import java.time.LocalDateTime;

public record ConversationView(
        Long conversationId,
        Long otherUserId,
        String otherUsername,
        String otherInitial,
        long unreadCount,
        String lastMessagePreview,
        LocalDateTime updatedAt
) {}
