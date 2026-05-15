package com.social.scuba_pal.social.post;

import com.social.scuba_pal.shared.VisibilityStatus;

import jakarta.validation.constraints.NotBlank;

import java.util.List;

public record CreateCurrentUserPostRequest(
        @NotBlank String caption,
        VisibilityStatus visibilityStatus,
        List<String> mediaUrls
) {
    public VisibilityStatus safeVisibilityStatus() {
        return visibilityStatus == null ? VisibilityStatus.PUBLIC : visibilityStatus;
    }
}
