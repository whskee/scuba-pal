package com.scubapal.identity.profile;

import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

import com.scubapal.shared.VisibilityStatus;

public record UpsertProfileRequest(
        @Size(max = 80) String firstName,
        @Size(max = 80) String lastName,
        @Size(max = 40) String phoneNumber,
        @Size(max = 120) String city,
        @Size(max = 120) String state,
        @Size(max = 120) String country,
        @Past LocalDate dateOfBirth,
        VisibilityStatus visibilityStatus,
        @PositiveOrZero Integer diveCount,
        @Size(max = 400) String bio,
        @Size(max = 500) String profileImageUrl
) {
}
