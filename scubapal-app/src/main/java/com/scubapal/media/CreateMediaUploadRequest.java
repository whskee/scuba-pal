package com.scubapal.media;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record CreateMediaUploadRequest(
        @NotNull MediaUploadPurpose purpose,
        @NotBlank @Size(max = 120) String contentType,
        @Size(max = 255) String fileName,
        @Positive Long contentLength
) {
}
