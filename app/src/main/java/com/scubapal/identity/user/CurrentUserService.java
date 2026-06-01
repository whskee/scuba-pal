package com.scubapal.identity.user;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.shared.exception.ResourceNotFoundException;

@Service
@Transactional(readOnly = true)
public class CurrentUserService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final PasswordEncoder passwordEncoder;
    private final IdentityMapper identityMapper;

    public CurrentUserService(UserRepository userRepository,
                              ProfileRepository profileRepository,
                              PasswordEncoder passwordEncoder,
                              IdentityMapper identityMapper) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.passwordEncoder = passwordEncoder;
        this.identityMapper = identityMapper;
    }

    public CurrentUserView getCurrentUser(String username) {
        User user = findActiveUser(username);
        Profile profile = profileRepository.findByUserId(user.getId()).orElse(null);
        return identityMapper.toCurrentUserView(user, profile);
    }

    @Transactional
    public CurrentUserView updateSettings(String username, UpdateSettingsForm form) {
        UpdateCurrentUserSettingsRequest request = new UpdateCurrentUserSettingsRequest(
                form.getProfileImageUrl(),
                form.getBio(),
                form.getCity(),
                form.getCountry(),
                form.getDiveCount());
        CurrentUserView updated = updateSettings(username, request);
        if (hasText(form.getNewPassword()) || hasText(form.getConfirmPassword()) || hasText(form.getCurrentPassword())) {
            changePassword(username, new ChangePasswordRequest(
                    form.getCurrentPassword(),
                    form.getNewPassword(),
                    form.getConfirmPassword()));
        }
        return updated;
    }

    @Transactional
    public CurrentUserView updateSettings(String username, UpdateCurrentUserSettingsRequest request) {
        User user = findActiveUser(username);
        Profile profile = profileRepository.findByUserId(user.getId()).orElseGet(() -> defaultProfile(user));
        profile.setProfileImageUrl(identityMapper.normalizeMediaUrl(request.profileImageUrl()));
        profile.setBio(blankToNull(request.bio()));
        profile.setCity(blankToNull(request.city()));
        profile.setCountry(blankToNull(request.country()));
        if (request.diveCount() != null) {
            profile.setDiveCount(request.diveCount());
        }
        profileRepository.save(profile);
        return identityMapper.toCurrentUserView(user, profile);
    }

    @Transactional
    public void changePassword(String username, ChangePasswordRequest request) {
        User user = findActiveUser(username);
        if (!hasText(request.currentPassword()) || !passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }
        if (!hasText(request.newPassword()) || !hasText(request.confirmPassword())) {
            throw new IllegalArgumentException("New password and confirmation are required");
        }
        if (!request.newPassword().equals(request.confirmPassword())) {
            throw new IllegalArgumentException("Passwords do not match");
        }
        validatePassword(request.newPassword());
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
    }

    private void validatePassword(String password) {
        if (password == null || password.length() < 12 || password.length() > 120) {
            throw new IllegalArgumentException("Password must be 12 to 120 characters.");
        }
    }

    private User findActiveUser(String username) {
        User user = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        if (!user.isActive()) {
            throw new IllegalArgumentException("User account is disabled");
        }
        return user;
    }

    private Profile defaultProfile(User user) {
        Profile profile = new Profile();
        profile.setUser(user);
        profile.setVisibilityStatus(VisibilityStatus.PUBLIC);
        profile.setDiveCount(0);
        return profile;
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
