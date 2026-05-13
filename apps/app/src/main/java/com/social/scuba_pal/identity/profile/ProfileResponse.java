package com.social.scuba_pal.identity.profile;

import com.social.scuba_pal.shared.VisibilityStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ProfileResponse(
        Long profileId,
        Long userId,
        String username,
        String firstName,
        String lastName,
        String phoneNumber,
        String city,
        String state,
        String country,
        LocalDate dateOfBirth,
        VisibilityStatus visibilityStatus,
        Integer diveCount,
        String bio,
        String profileImageUrl,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
