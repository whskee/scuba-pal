package com.scubapal.social.post;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

import com.scubapal.shared.VisibilityStatus;

public record CreatePostRequest(
        @NotNull Long userId,
        @NotBlank String caption,
        @NotNull VisibilityStatus visibilityStatus,
        List<String> mediaUrls
) {
}
