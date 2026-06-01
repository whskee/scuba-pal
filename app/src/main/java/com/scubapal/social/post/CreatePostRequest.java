package com.scubapal.social.post;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

import com.scubapal.shared.VisibilityStatus;

public record CreatePostRequest(
        @NotNull Long userId,
        @NotBlank @Size(max = 500) String caption,
        @NotNull VisibilityStatus visibilityStatus,
        @Size(max = 10) List<@NotBlank @Size(max = 500) String> mediaUrls
) {
}
