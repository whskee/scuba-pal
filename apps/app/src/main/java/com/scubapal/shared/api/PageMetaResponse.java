package com.scubapal.shared.api;

public record PageMetaResponse(
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean hasNext
) {
}