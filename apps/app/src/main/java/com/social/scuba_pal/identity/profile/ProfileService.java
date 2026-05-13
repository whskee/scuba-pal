package com.social.scuba_pal.identity.profile;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.identity.user.UserRepository;
import com.social.scuba_pal.shared.VisibilityStatus;
import com.social.scuba_pal.shared.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class ProfileService {

    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;

    public ProfileService(ProfileRepository profileRepository, UserRepository userRepository) {
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
    }

    public ProfileResponse getByUserId(Long userId) {
        return toResponse(getProfileEntityByUserId(userId));
    }

    private Profile getProfileEntityByUserId(Long userId) {
        return profileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found for user: " + userId));
    }

    @Transactional
    public ProfileResponse create(Long userId, UpsertProfileRequest input) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        if (profileRepository.findByUserId(userId).isPresent()) {
            throw new IllegalArgumentException("Profile already exists for user: " + userId);
        }

        Profile profile = new Profile();
        profile.setUser(user);
        profile.setFirstName(input.firstName());
        profile.setLastName(input.lastName());
        profile.setPhoneNumber(input.phoneNumber());
        profile.setCity(input.city());
        profile.setState(input.state());
        profile.setCountry(input.country());
        profile.setDateOfBirth(input.dateOfBirth());
        profile.setBio(input.bio());
        profile.setProfileImageUrl(input.profileImageUrl());
        profile.setVisibilityStatus(
                input.visibilityStatus() != null ? input.visibilityStatus() : VisibilityStatus.PUBLIC);
        profile.setDiveCount(input.diveCount() != null ? input.diveCount() : 0);

        return toResponse(profileRepository.save(profile));
    }

    @Transactional
    public ProfileResponse update(Long userId, UpsertProfileRequest input) {
        Profile existing = getProfileEntityByUserId(userId);

        existing.setFirstName(input.firstName());
        existing.setLastName(input.lastName());
        existing.setPhoneNumber(input.phoneNumber());
        existing.setCity(input.city());
        existing.setState(input.state());
        existing.setCountry(input.country());
        existing.setDateOfBirth(input.dateOfBirth());
        existing.setVisibilityStatus(
                input.visibilityStatus() != null ? input.visibilityStatus() : existing.getVisibilityStatus());
        existing.setDiveCount(input.diveCount() != null ? input.diveCount() : existing.getDiveCount());
        existing.setBio(input.bio());
        existing.setProfileImageUrl(input.profileImageUrl());

        return toResponse(profileRepository.save(existing));
    }

    private ProfileResponse toResponse(Profile profile) {
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
                profile.getProfileImageUrl(),
                profile.getCreatedAt(),
                profile.getUpdatedAt());
    }
}
