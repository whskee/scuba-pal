package com.scubapal.social.post;

import java.time.LocalDateTime;
import java.util.List;

import com.scubapal.shared.VisibilityStatus;

public record FeedPostView(
        Long postId,
        Long userId,
        String username,
        String authorProfileImageUrl,
        String caption,
        VisibilityStatus visibilityStatus,
        String imageUrl,
        List<String> mediaUrls,
        long likes,
        long comments,
        LocalDateTime createdAt
) {
}
