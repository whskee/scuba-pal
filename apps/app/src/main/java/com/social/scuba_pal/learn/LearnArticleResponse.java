package com.social.scuba_pal.learn;

import java.time.LocalDateTime;

public record LearnArticleResponse(
        Long articleId,
        String slug,
        String title,
        String summary,
        String content,
        String category,
        String difficultyLevel,
        Integer estimatedMinutes,
        LocalDateTime updatedAt
) {
}
