package com.social.scuba_pal.social.post;

import com.social.scuba_pal.shared.VisibilityStatus;

import jakarta.validation.constraints.NotBlank;

public record CreateCurrentUserPostRequest(
        @NotBlank String caption,
        VisibilityStatus visibilityStatus
) {
    public VisibilityStatus safeVisibilityStatus() {
        return visibilityStatus == null ? VisibilityStatus.PUBLIC : visibilityStatus;
    }
}
