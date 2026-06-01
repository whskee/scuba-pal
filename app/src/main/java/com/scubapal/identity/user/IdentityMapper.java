package com.scubapal.identity.user;

import org.springframework.stereotype.Component;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileResponse;
import com.scubapal.media.MediaStorageService;

@Component
public class IdentityMapper {

    private final MediaStorageService mediaStorageService;

    public IdentityMapper(MediaStorageService mediaStorageService) {
        this.mediaStorageService = mediaStorageService;
    }

    public UserView toUserView(User user, Profile profile) {
        return new UserView(
                user.getId(),
                user.getUsername(),
                profile != null ? profile.getFirstName() : null,
                profile != null ? profile.getLastName() : null,
                user.getEmail(),
                user.getRole().getName(),
                profile != null ? profile.getCity() : null,
                profile != null ? profile.getCountry() : null,
                profile != null ? profile.getDiveCount() : 0,
                profile != null ? profile.getBio() : null,
                profile != null ? normalizeMediaUrl(profile.getProfileImageUrl()) : null);
    }

    public ProfileResponse toProfileResponse(Profile profile) {
        User user = profile.getUser();
        return new ProfileResponse(
                profile.getId(),
                user.getId(),
                user.getUsername(),
                profile.getFirstName(),
                profile.getLastName(),
                profile.getPhoneNumber(),
                profile.getCity(),
                profile.getState(),
                profile.getCountry(),
                profile.getDateOfBirth(),
                profile.getVisibilityStatus(),
                profile.getDiveCount(),
                profile.getBio(),
                normalizeMediaUrl(profile.getProfileImageUrl()),
                profile.getCreatedAt(),
                profile.getUpdatedAt());
    }

    public String normalizeMediaUrl(String mediaUrl) {
        return mediaUrl == null || mediaUrl.isBlank() ? null : mediaStorageService.normalizeManagedUrl(mediaUrl);
    }
}
