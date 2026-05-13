package com.social.scuba_pal.identity.user;

public record UserView(
        Long id,
        String username,
        String email,
        String role,
        String city,
        String country,
        Integer diveCount,
        String bio,
        String profileImageUrl
) {
}
