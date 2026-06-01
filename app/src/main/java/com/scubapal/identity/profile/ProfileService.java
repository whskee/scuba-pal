package com.scubapal.identity.profile;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.user.IdentityMapper;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.shared.exception.ResourceNotFoundException;

import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class ProfileService {

    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;
    private final IdentityMapper identityMapper;

    public ProfileService(ProfileRepository profileRepository, UserRepository userRepository, IdentityMapper identityMapper) {
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
        this.identityMapper = identityMapper;
    }

    public ProfileResponse getByUserId(Long userId) {
        return identityMapper.toProfileResponse(getProfileEntityByUserId(userId));
    }

    public PublicProfileResponse getPublicByUserId(Long userId) {
        Profile profile = getProfileEntityByUserId(userId);
        if (profile.getVisibilityStatus() != VisibilityStatus.PUBLIC) {
            throw new ResourceNotFoundException("Profile not found for user: " + userId);
        }
        return identityMapper.toPublicProfileResponse(profile);
    }

    public ProfileResponse getCurrentUserProfile(String username) {
        User user = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        return getByUserId(user.getId());
    }

    public Optional<Profile> findProfileEntityByUserId(Long userId) {
        return profileRepository.findByUserId(userId);
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
        applyProfileFields(profile, input, true);

        return identityMapper.toProfileResponse(profileRepository.save(profile));
    }

    @Transactional
    public ProfileResponse update(Long userId, UpsertProfileRequest input) {
        Profile existing = getProfileEntityByUserId(userId);
        applyProfileFields(existing, input, false);
        return identityMapper.toProfileResponse(profileRepository.save(existing));
    }

    @Transactional
    public ProfileResponse updateCurrentUserProfile(String username, UpsertProfileRequest input) {
        User user = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        return update(user.getId(), input);
    }

    @Transactional
    public Profile createDefaultProfileForUser(User user,
                                               String firstName,
                                               String lastName,
                                               String city,
                                               String country) {
        Profile profile = new Profile();
        profile.setUser(user);
        profile.setFirstName(blankToNull(firstName));
        profile.setLastName(blankToNull(lastName));
        profile.setCity(blankToNull(city));
        profile.setCountry(blankToNull(country));
        profile.setVisibilityStatus(VisibilityStatus.PUBLIC);
        profile.setDiveCount(0);
        return profileRepository.save(profile);
    }

    private void applyProfileFields(Profile profile, UpsertProfileRequest input, boolean creating) {
        profile.setFirstName(blankToNull(input.firstName()));
        profile.setLastName(blankToNull(input.lastName()));
        profile.setPhoneNumber(blankToNull(input.phoneNumber()));
        profile.setCity(blankToNull(input.city()));
        profile.setState(blankToNull(input.state()));
        profile.setCountry(blankToNull(input.country()));
        profile.setDateOfBirth(input.dateOfBirth());
        profile.setBio(blankToNull(input.bio()));
        profile.setProfileImageUrl(identityMapper.normalizeMediaUrl(input.profileImageUrl()));
        profile.setVisibilityStatus(input.visibilityStatus() != null
                ? input.visibilityStatus()
                : creating ? VisibilityStatus.PUBLIC : profile.getVisibilityStatus());
        profile.setDiveCount(input.diveCount() != null ? input.diveCount() : creating ? 0 : profile.getDiveCount());
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
