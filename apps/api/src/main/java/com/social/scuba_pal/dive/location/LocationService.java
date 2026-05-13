package com.social.scuba_pal.dive.location;

import com.social.scuba_pal.shared.exception.ResourceNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class LocationService {

    private final DiveLocationRepository diveLocationRepository;

    public LocationService(DiveLocationRepository diveLocationRepository) {
        this.diveLocationRepository = diveLocationRepository;
    }

    public List<DiveLocation> getLocations(String city) {
        return getLocations(city, Pageable.ofSize(20)).getContent();
    }

    public Page<DiveLocation> getLocations(String city, Pageable pageable) {
        if (city == null || city.isBlank()) {
            return diveLocationRepository.findAll(pageable);
        }
        return diveLocationRepository.findByCityIgnoreCaseOrderByPopularityScoreDesc(city, pageable);
    }

    public DiveLocation getLocation(Long locationId) {
        return diveLocationRepository.findById(locationId)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found: " + locationId));
    }

    @Transactional
    public DiveLocation createLocation(CreateLocationRequest request) {
        DiveLocation location = new DiveLocation();
        location.setLocationName(request.locationName());
        location.setDescription(request.description());
        location.setCity(request.city());
        location.setState(request.state());
        location.setCountry(request.country());
        location.setLatitude(request.latitude());
        location.setLongitude(request.longitude());
        location.setDifficultyLevel(request.difficultyLevel());
        location.setPopularityScore(0);
        return diveLocationRepository.save(location);
    }
}
