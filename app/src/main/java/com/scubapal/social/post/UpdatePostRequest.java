package com.scubapal.social.post;

import java.util.List;

import com.scubapal.shared.VisibilityStatus;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdatePostRequest(
        @NotBlank
        @Size(max = 500)
        String caption,

        @NotNull
        VisibilityStatus visibilityStatus,

        @Size(max = 10)
        List<@NotBlank String> mediaUrls
) {
}