package com.scubapal.media;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record CreateMediaUploadRequest(
        @NotNull MediaUploadPurpose purpose,
        @NotBlank String contentType,
        String fileName,
        @Positive Long contentLength
) {
}
