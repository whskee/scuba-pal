package com.scubapal.dive.location;

public record DiveLocationView(
        Long locationId,
        String locationName,
        String description,
        String city,
        String state,
        String country,
        String difficultyLevel,
        Integer popularityScore,
        String imageUrl
) {
}
