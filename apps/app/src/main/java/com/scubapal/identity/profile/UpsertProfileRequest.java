package com.scubapal.identity.profile;

import jakarta.validation.constraints.PositiveOrZero;

import java.time.LocalDate;

import com.scubapal.shared.VisibilityStatus;

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