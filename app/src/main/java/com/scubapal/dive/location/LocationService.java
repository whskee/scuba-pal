package com.scubapal.dive.location;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.shared.domain.address.Coordinates;
import com.scubapal.shared.exception.ResourceNotFoundException;

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
        // location.setLatitude(request.latitude());
        // location.setLongitude(request.longitude());
        location.setCoordinates(new Coordinates(request.latitude(), request.longitude()));
        location.setDifficultyLevel(request.difficultyLevel());
        location.setPopularityScore(0);
        return diveLocationRepository.save(location);
    }

    // This is a better way to do it
    // @Transactional
    // public DiveLocation createLocation(CreateLocationRequest request) {
    //     // 1. Business Validation
    //     if (diveLocationRepository.existsByLocationName(request.locationName())) {
    //         throw new DuplicateLocationException("Location name already exists");
    //     }

    //     // 2. Clear Object Mapping
    //     DiveLocation location = DiveLocation.builder()
    //             .locationName(request.locationName())
    //             .description(request.description())
    //             .city(request.city())
    //             .state(request.state())
    //             .country(request.country())
    //             .coordinates(new Coordinates(request.latitude(), request.longitude()))
    //             .difficultyLevel(request.difficultyLevel())
    //             .popularityScore(0) // Default business initialization
    //             .build();

    //     // 3. Persistence
    //     return diveLocationRepository.save(location);
    // }

}
