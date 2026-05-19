package com.scubapal.media;

import java.time.Instant;
import java.util.Map;

public record MediaUploadResponse(
        String objectKey,
        String uploadUrl,
        String publicUrl,
        String method,
        Map<String, String> headers,
        Instant expiresAt,
        long maxBytes
) {
}
