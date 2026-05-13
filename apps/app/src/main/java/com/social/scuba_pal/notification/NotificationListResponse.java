package com.social.scuba_pal.notification;

import com.social.scuba_pal.shared.api.PageMetaResponse;

import java.util.List;

public record NotificationListResponse(
        List<NotificationView> notifications,
        PageMetaResponse page
) {
}