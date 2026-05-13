package com.social.scuba_pal.dive.location;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CreateLocationRequest(
        @NotBlank String locationName,
        String description,
        String city,
        String state,
        String country,
        @NotNull BigDecimal latitude,
        @NotNull BigDecimal longitude,
        String difficultyLevel
) {
}
