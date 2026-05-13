package com.social.scuba_pal.social.post;

import java.time.LocalDateTime;

import com.social.scuba_pal.shared.VisibilityStatus;

public record FeedPostView(
        Long postId,
        Long userId,
        String username,
        String caption,
        VisibilityStatus visibilityStatus,
        long likes,
        long comments,
        LocalDateTime createdAt
) {
}
