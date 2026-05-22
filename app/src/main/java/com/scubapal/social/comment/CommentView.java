package com.scubapal.social.comment;

import java.time.LocalDateTime;

// TODO: Later, you should also add comment author avatars to CommentView, but do post author first.
public record CommentView(
        Long commentId,
        Long userId,
        String username,
        String commentText,
        LocalDateTime createdAt
) {
}
