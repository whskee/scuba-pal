package com.scubapal.messaging.message;

import java.util.List;

import com.scubapal.shared.api.PageMetaResponse;

public record MessageListResponse(
        List<MessageView> messages,
        PageMetaResponse page
) {
}