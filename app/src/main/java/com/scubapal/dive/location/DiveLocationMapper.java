package com.scubapal.dive.location;

import com.scubapal.shared.domain.address.Coordinates;

import java.math.BigDecimal;

import org.springframework.stereotype.Component;

@Component
public class DiveLocationMapper {

    public DiveLocationResponse toResponse(DiveLocation location) {
        Coordinates coordinates = location.getCoordinates();
        BigDecimal latitude = coordinates != null ? coordinates.getLatitude() : null;
        BigDecimal longitude = coordinates != null ? coordinates.getLongitude() : null;

        return new DiveLocationResponse(
                location.getId(),
                location.getLocationName(),
                location.getDescription(),
                location.getImageUrl(),
                location.getCity(),
                location.getState(),
                location.getCountry(),
                latitude,
                longitude,
                location.getDifficultyLevel(),
                location.getPopularityScore()
        );
    }
}
