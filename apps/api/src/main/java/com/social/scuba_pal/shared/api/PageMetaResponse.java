package com.social.scuba_pal.shared.api;

public record PageMetaResponse(
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean hasNext
) {
}