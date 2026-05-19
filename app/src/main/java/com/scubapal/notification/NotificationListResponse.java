package com.scubapal.notification;

import java.util.List;

import com.scubapal.shared.api.PageMetaResponse;

public record NotificationListResponse(
        List<NotificationView> notifications,
        PageMetaResponse page
) {
}