package com.social.scuba_pal.social.post;

import com.social.scuba_pal.shared.VisibilityStatus;
import com.social.scuba_pal.social.comment.CommentView;

import java.time.LocalDateTime;
import java.util.List;

public record PostDetailView(
        Long postId,
        Long userId,
        String username,
        String caption,
        VisibilityStatus visibilityStatus,
        long likes,
        long comments,
        boolean likedByCurrentUser,
        LocalDateTime createdAt,
        List<CommentView> commentList
) {
}
