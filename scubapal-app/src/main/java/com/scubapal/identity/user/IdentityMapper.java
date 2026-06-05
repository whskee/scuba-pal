package com.scubapal.identity.user;

import org.springframework.stereotype.Component;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileResponse;
import com.scubapal.identity.profile.PublicProfileResponse;
import com.scubapal.media.MediaStorageService;

@Component
public class IdentityMapper {

    private final MediaStorageService mediaStorageService;

    public IdentityMapper(MediaStorageService mediaStorageService) {
        this.mediaStorageService = mediaStorageService;
    }

    public UserView toUserView(User user, Profile profile) {
        CurrentUserView view = toCurrentUserView(user, profile);
        return new UserView(
                view.id(),
                view.username(),
                view.firstName(),
                view.lastName(),
                view.email(),
                view.role(),
                view.city(),
                view.country(),
                view.diveCount(),
                view.bio(),
                view.profileImageUrl());
    }

    public PublicUserView toPublicUserView(User user, Profile profile) {
        return new PublicUserView(
                user.getId(),
                user.getUsername(),
                profile != null ? profile.getFirstName() : null,
                profile != null ? profile.getLastName() : null,
                profile != null ? profile.getCity() : null,
                profile != null ? profile.getCountry() : null,
                profile != null ? profile.getDiveCount() : 0,
                profile != null ? profile.getBio() : null,
                profile != null ? normalizeMediaUrl(profile.getProfileImageUrl()) : null);
    }

    public CurrentUserView toCurrentUserView(User user, Profile profile) {
        return new CurrentUserView(
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

    public AdminUserView toAdminUserView(User user, Profile profile) {
        return new AdminUserView(
                user.getId(),
                user.getUsername(),
                profile != null ? profile.getFirstName() : null,
                profile != null ? profile.getLastName() : null,
                user.getEmail(),
                user.getRole().getName(),
                user.isActive(),
                profile != null ? profile.getCity() : null,
                profile != null ? profile.getCountry() : null,
                profile != null ? profile.getDiveCount() : 0,
                profile != null ? profile.getBio() : null,
                profile != null ? normalizeMediaUrl(profile.getProfileImageUrl()) : null,
                user.getCreatedAt(),
                user.getLastLoginAt());
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

    public PublicProfileResponse toPublicProfileResponse(Profile profile) {
        User user = profile.getUser();
        return new PublicProfileResponse(
                user.getId(),
                user.getUsername(),
                profile.getFirstName(),
                profile.getLastName(),
                profile.getCity(),
                profile.getCountry(),
                profile.getDiveCount(),
                profile.getBio(),
                normalizeMediaUrl(profile.getProfileImageUrl()));
    }

    public String normalizeMediaUrl(String mediaUrl) {
        return mediaUrl == null || mediaUrl.isBlank() ? null : mediaStorageService.normalizeManagedUrl(mediaUrl);
    }
}
