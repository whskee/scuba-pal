package com.scubapal.social.post;

import java.time.LocalDateTime;
import java.util.List;

import com.scubapal.shared.VisibilityStatus;
import com.scubapal.social.comment.CommentView;

public record PostDetailView(
        Long postId,
        Long userId,
        String username,
        String caption,
        VisibilityStatus visibilityStatus,
        String imageUrl,
        List<String> mediaUrls,
        long likes,
        long comments,
        boolean likedByCurrentUser,
        LocalDateTime createdAt,
        List<CommentView> commentList
) {
}
