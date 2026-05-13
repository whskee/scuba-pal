package com.social.scuba_pal.identity.profile;

import com.social.scuba_pal.shared.VisibilityStatus;
import jakarta.validation.constraints.PositiveOrZero;

import java.time.LocalDate;

public record UpsertProfileRequest(
        String firstName,
        String lastName,
        String phoneNumber,
        String city,
        String state,
        String country,
        LocalDate dateOfBirth,
        VisibilityStatus visibilityStatus,
        @PositiveOrZero Integer diveCount,
        String bio,
        String profileImageUrl
) {
}