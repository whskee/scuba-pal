package com.scubapal.identity.profile;

public record PublicProfileResponse(
        Long userId,
        String username,
        String firstName,
        String lastName,
        String city,
        String country,
        Integer diveCount,
        String bio,
        String profileImageUrl
) {
}
