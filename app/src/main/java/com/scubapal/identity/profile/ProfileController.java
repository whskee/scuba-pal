package com.scubapal.identity.profile;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Profiles", description = "Endpoints for creating and managing diver profiles")
@RestController
@RequestMapping("/api")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @PostMapping("/profiles/{userId}")
    @PreAuthorize("hasAnyRole('ADMIN','MODERATOR')")
    @Operation(summary = "Create profile", description = "Creates a profile for a user if one does not already exist.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Profile created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<ProfileResponse> create(@PathVariable Long userId, @Valid @RequestBody UpsertProfileRequest input) {
        return ResponseEntity.status(HttpStatus.CREATED).body(profileService.create(userId, input));
    }

    @GetMapping({"/profiles/{userId}", "/users/{userId}/profile"})
    @Operation(summary = "Get profile", description = "Returns profile details for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Profile returned"),
            @ApiResponse(responseCode = "404", description = "Profile not found")
    })
    public ProfileResponse get(@PathVariable Long userId) {
        return profileService.getByUserId(userId);
    }

    @PutMapping("/profiles/{userId}")
    @PreAuthorize("hasAnyRole('ADMIN','MODERATOR')")
    @Operation(summary = "Update profile", description = "Updates profile details for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Profile updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Profile not found")
    })
    public ProfileResponse update(@PathVariable Long userId, @Valid @RequestBody UpsertProfileRequest input) {
        return profileService.update(userId, input);
    }

    @GetMapping("/me/profile")
    @Operation(summary = "Get current user's profile", description = "Returns profile details for the authenticated user.")
    public ProfileResponse currentProfile(java.security.Principal principal) {
        return profileService.getCurrentUserProfile(principal.getName());
    }

    @PutMapping("/me/profile")
    @Operation(summary = "Update current user's profile", description = "Updates profile details for the authenticated user.")
    public ProfileResponse updateCurrentProfile(java.security.Principal principal,
                                                @Valid @RequestBody UpsertProfileRequest input) {
        return profileService.updateCurrentUserProfile(principal.getName(), input);
    }
}
