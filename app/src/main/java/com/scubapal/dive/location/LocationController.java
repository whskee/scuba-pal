package com.scubapal.dive.location;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.scubapal.shared.domain.address.Coordinates;

import java.math.BigDecimal;
import java.util.List;

@Tag(name = "Dive Locations", description = "Endpoints for discovering and creating dive locations")
@RestController
@RequestMapping("/api/locations")
public class LocationController {

    private final LocationService locationService;

    public LocationController(LocationService locationService) {
        this.locationService = locationService;
    }

    @GetMapping
    @Operation(summary = "List dive locations", description = "Returns dive locations, optionally filtered by city.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Location list returned")
    })
    public List<DiveLocationResponse> getAll(@RequestParam(required = false) String city) {
        return locationService.getLocations(city).stream().map(this::toResponse).toList();
    }

    @PostMapping
    @Operation(summary = "Create dive location", description = "Creates a new dive location.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Location created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Authentication required")
    })
    public ResponseEntity<DiveLocationResponse> create(@Valid @RequestBody CreateLocationRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(locationService.createLocation(request)));
    }

    private DiveLocationResponse toResponse(DiveLocation location) {
        // Handle the case where coordinates might be null in the database
        Coordinates coordinates = location.getCoordinates();
        BigDecimal latitude = (coordinates != null) ? coordinates.getLatitude() : null;
        BigDecimal longitude = (coordinates != null) ? coordinates.getLongitude() : null;

        return new DiveLocationResponse(
                location.getId(),
                location.getLocationName(),
                location.getDescription(),
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
