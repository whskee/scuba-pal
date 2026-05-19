package com.scubapal.messaging.conversation;

import java.util.List;

import com.scubapal.shared.api.PageMetaResponse;

public record ConversationListResponse(
        List<ConversationView> conversations,
        PageMetaResponse page
) {
}