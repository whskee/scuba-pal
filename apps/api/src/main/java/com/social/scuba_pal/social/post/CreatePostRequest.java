package com.social.scuba_pal.social.post;

import com.social.scuba_pal.shared.VisibilityStatus;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record CreatePostRequest(
        @NotNull Long userId,
        @NotBlank String caption,
        @NotNull VisibilityStatus visibilityStatus,
        List<String> mediaUrls
) {
}
