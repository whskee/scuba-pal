package com.scubapal.messaging.message;

import java.util.List;

import com.scubapal.shared.api.PageMetaResponse;

public record DirectMessageListResponse(
        List<DirectMessageView> messages,
        PageMetaResponse page
) {
}