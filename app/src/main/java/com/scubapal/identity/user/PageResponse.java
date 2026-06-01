package com.scubapal.identity.user;

import java.util.List;

import org.springframework.data.domain.Page;

import com.scubapal.shared.api.PageMetaResponse;

public record PageResponse<T>(
        List<T> content,
        PageMetaResponse meta
) {
    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getContent(),
                new PageMetaResponse(
                        page.getNumber(),
                        page.getSize(),
                        page.getTotalElements(),
                        page.getTotalPages(),
                        page.hasNext()));
    }
}
