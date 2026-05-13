package com.social.scuba_pal.identity.profile;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Profiles", description = "Endpoints for creating and managing diver profiles")
@RestController
@RequestMapping("/api/profiles")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @PostMapping("/{userId}")
    @Operation(summary = "Create profile", description = "Creates a profile for a user if one does not already exist.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Profile created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<ProfileResponse> create(@PathVariable Long userId, @Valid @RequestBody UpsertProfileRequest input) {
        return ResponseEntity.status(HttpStatus.CREATED).body(profileService.create(userId, input));
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Get profile", description = "Returns profile details for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Profile returned"),
            @ApiResponse(responseCode = "404", description = "Profile not found")
    })
    public ProfileResponse get(@PathVariable Long userId) {
        return profileService.getByUserId(userId);
    }

    @PutMapping("/{userId}")
    @Operation(summary = "Update profile", description = "Updates profile details for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Profile updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Profile not found")
    })
    public ProfileResponse update(@PathVariable Long userId, @Valid @RequestBody UpsertProfileRequest input) {
        return profileService.update(userId, input);
    }
}
