package com.scubapal.social.post;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

import com.scubapal.shared.VisibilityStatus;

public record CreateCurrentUserPostRequest(
        @NotBlank @Size(max = 500) String caption,
        VisibilityStatus visibilityStatus,
        @Size(max = 10) List<@NotBlank @Size(max = 500) String> mediaUrls
) {
    public VisibilityStatus safeVisibilityStatus() {
        return visibilityStatus == null ? VisibilityStatus.PUBLIC : visibilityStatus;
    }
}
