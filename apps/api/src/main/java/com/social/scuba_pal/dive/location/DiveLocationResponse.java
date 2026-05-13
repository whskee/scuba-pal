package com.social.scuba_pal.dive.location;

import java.math.BigDecimal;

public record DiveLocationResponse(
        Long locationId,
        String locationName,
        String description,
        String city,
        String state,
        String country,
        BigDecimal latitude,
        BigDecimal longitude,
        String difficultyLevel,
        Integer popularityScore
) {
}