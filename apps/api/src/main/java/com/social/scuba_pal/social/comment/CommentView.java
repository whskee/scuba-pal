package com.social.scuba_pal.social.comment;

import java.time.LocalDateTime;

public record CommentView(
        Long commentId,
        Long userId,
        String username,
        String commentText,
        LocalDateTime createdAt
) {
}
