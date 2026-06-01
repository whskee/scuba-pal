package com.scubapal.identity.user;

import java.time.LocalDateTime;

public record AdminUserView(
        Long id,
        String username,
        String firstName,
        String lastName,
        String email,
        String role,
        boolean active,
        String city,
        String country,
        Integer diveCount,
        String bio,
        String profileImageUrl,
        LocalDateTime createdAt,
        LocalDateTime lastLoginAt
) {
}
