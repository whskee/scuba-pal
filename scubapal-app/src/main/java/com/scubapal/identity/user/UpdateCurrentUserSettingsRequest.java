package com.scubapal.identity.user;

import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record UpdateCurrentUserSettingsRequest(
        @Size(max = 500) String profileImageUrl,
        @Size(max = 400) String bio,
        @Size(max = 120) String city,
        @Size(max = 120) String country,
        @PositiveOrZero Integer diveCount
) {
}
