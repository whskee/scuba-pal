package com.social.scuba_pal.messaging.message;

import com.social.scuba_pal.shared.api.PageMetaResponse;

import java.util.List;

public record DirectMessageListResponse(
        List<DirectMessageView> messages,
        PageMetaResponse page
) {
}