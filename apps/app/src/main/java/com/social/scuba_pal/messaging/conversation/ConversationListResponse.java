package com.social.scuba_pal.messaging.conversation;

import com.social.scuba_pal.shared.api.PageMetaResponse;

import java.util.List;

public record ConversationListResponse(
        List<ConversationView> conversations,
        PageMetaResponse page
) {
}