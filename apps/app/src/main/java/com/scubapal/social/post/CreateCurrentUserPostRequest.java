package com.scubapal.social.post;

import jakarta.validation.constraints.NotBlank;

import java.util.List;

import com.scubapal.shared.VisibilityStatus;

public record CreateCurrentUserPostRequest(
        @NotBlank String caption,
        VisibilityStatus visibilityStatus,
        List<String> mediaUrls
) {
    public VisibilityStatus safeVisibilityStatus() {
        return visibilityStatus == null ? VisibilityStatus.PUBLIC : visibilityStatus;
    }
}
