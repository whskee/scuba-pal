package com.scubapal.dive.location;

import java.math.BigDecimal;

public record DiveLocationResponse(
        Long locationId,
        String locationName,
        String description,
        String imageUrl,
        String city,
        String state,
        String country,
        BigDecimal latitude,
        BigDecimal longitude,
        String difficultyLevel,
        Integer popularityScore
) {
}
