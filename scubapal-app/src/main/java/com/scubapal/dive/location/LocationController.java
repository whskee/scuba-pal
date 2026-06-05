package com.scubapal.dive.location;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.scubapal.shared.api.PageResponse;

@Tag(name = "Dive Locations", description = "Endpoints for discovering and creating dive locations")
@RestController
@RequestMapping("/api/locations")
public class LocationController {

    private final LocationService locationService;
    private final DiveLocationMapper diveLocationMapper;

    public LocationController(LocationService locationService, DiveLocationMapper diveLocationMapper) {
        this.locationService = locationService;
        this.diveLocationMapper = diveLocationMapper;
    }

    @GetMapping
    @Operation(summary = "List dive locations", description = "Returns dive locations, optionally filtered by city.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Location list returned")
    })
    public PageResponse<DiveLocationResponse> getAll(@RequestParam(required = false) String city,
                                                     @RequestParam(defaultValue = "0") int page,
                                                     @RequestParam(defaultValue = "20") int size) {
        return PageResponse.from(
                locationService.getLocations(city, PageRequest.of(
                                Math.max(page, 0),
                                Math.min(Math.max(size, 1), 100)))
                        .map(diveLocationMapper::toResponse));
    }

    @PostMapping
    @Operation(summary = "Create dive location", description = "Creates a new dive location.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Location created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Authentication required")
    })
    public ResponseEntity<DiveLocationResponse> create(@Valid @RequestBody CreateLocationRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(diveLocationMapper.toResponse(locationService.createLocation(request)));
    }
}
