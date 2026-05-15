package com.social.scuba_pal.social.post;

import java.time.LocalDateTime;
import java.util.List;

import com.social.scuba_pal.shared.VisibilityStatus;

public record FeedPostView(
        Long postId,
        Long userId,
        String username,
        String caption,
        VisibilityStatus visibilityStatus,
        String imageUrl,
        List<String> mediaUrls,
        long likes,
        long comments,
        LocalDateTime createdAt
) {
}
