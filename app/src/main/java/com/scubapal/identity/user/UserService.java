package com.scubapal.identity.user;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.mail.MailException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.auth.LoginRequest;
import com.scubapal.identity.auth.PasswordResetToken;
import com.scubapal.identity.auth.PasswordResetTokenRepository;
import com.scubapal.identity.auth.RegisterRequest;
import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.identity.role.Role;
import com.scubapal.identity.role.RoleRepository;
import com.scubapal.media.MediaStorageService;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.shared.exception.ResourceNotFoundException;
import com.scubapal.shared.mail.EmailService;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProfileRepository profileRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final MediaStorageService mediaStorageService;
    private final String appBaseUrl;

    public UserService(UserRepository userRepository,
                       RoleRepository roleRepository,
                       ProfileRepository profileRepository,
                       PasswordResetTokenRepository passwordResetTokenRepository,
                       PasswordEncoder passwordEncoder,
                       EmailService emailService,
                       MediaStorageService mediaStorageService,
                       @Value("${app.base-url:http://localhost:8080}") String appBaseUrl) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.profileRepository = profileRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        this.mediaStorageService = mediaStorageService;
        this.appBaseUrl = appBaseUrl;
    }

    @Transactional
    public boolean isUsernameAvailable(String username) {
        if (username == null || username.trim().length() < 3) {
            return false;
        }
        return userRepository.findByUsername(username.trim()).isEmpty();
    }

    @Transactional
    public UserView register(RegisterRequest request) {
        userRepository.findByEmailIgnoreCase(request.email()).ifPresent(user -> {
            throw new IllegalArgumentException("Email already in use");
        });
        userRepository.findByUsername(request.username()).ifPresent(user -> {
            throw new IllegalArgumentException("Username already in use");
        });

        Role role = roleRepository.findByName("user")
                .orElseThrow(() -> new ResourceNotFoundException("Default role not found"));

        User user = new User();
        user.setEmail(request.email().trim().toLowerCase());
        user.setUsername(request.username().trim());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setRole(role);
        user.setActive(true);
        user.setEmailVerifiedAt(LocalDateTime.now());
        user.setLastLoginAt(LocalDateTime.now());
        User savedUser = userRepository.save(user);

        Profile profile = new Profile();
        profile.setUser(savedUser);
        profile.setFirstName(request.firstName());
        profile.setLastName(request.lastName());
        profile.setCity(request.city());
        profile.setCountry(request.country());
        profile.setVisibilityStatus(VisibilityStatus.PUBLIC);
        profile.setDiveCount(0);
        profileRepository.save(profile);

        return toUserView(savedUser, profile);
    }

    @Transactional
    public UserView login(LoginRequest request) {
        User user = userRepository.findByUsername(request.username())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid credentials");
        }

        user.setLastLoginAt(LocalDateTime.now());
        Profile profile = profileRepository.findByUserId(user.getId()).orElse(null);
        return toUserView(user, profile);
    }

    @Transactional
    public void sendPasswordResetLink(String emailOrUsername) {
        String lookup = emailOrUsername == null ? "" : emailOrUsername.trim();
        if (lookup.isBlank()) {
            return;
        }

        userRepository.findByEmailIgnoreCase(lookup)
                .or(() -> userRepository.findByUsername(lookup))
                .ifPresent(user -> {
                    PasswordResetToken resetToken = new PasswordResetToken();
                    resetToken.setUser(user);
                    resetToken.setToken(UUID.randomUUID().toString().replace("-", ""));
                    resetToken.setExpiresAt(Instant.now().plusSeconds(3600)); // 1 hour expiry
                    PasswordResetToken saved = passwordResetTokenRepository.save(resetToken);
                    String link = appBaseUrl.replaceAll("/+$", "") + "/reset-password?token=" + saved.getToken();
                    try {
                        emailService.sendPasswordResetEmail(user.getEmail(), user.getUsername(), link);
                    } catch (MailException ex) {
                        // Keep the reset token usable even when local SMTP is missing or unavailable.
                        log.warn("Could not send password reset email to {}: {}. Reset link: {}", user.getEmail(),
                                ex.getMessage(), link);

                        // Use the below line in production to disable the reset token when email sending fails, preventing potential security issues.
                        // log.warn("Could not send password reset email to {}: {}", user.getEmail(), ex.getMessage());
                        // passwordResetTokenRepository.delete(resetToken);
                    }
                });
    }

    @Transactional
    public boolean isPasswordResetTokenUsable(String token) {
        return passwordResetTokenRepository.findByToken(token)
                .map(PasswordResetToken::isUsable)
                .orElse(false);
    }

    @Transactional
    public void resetPassword(String token, String newPassword, String confirmPassword) {
        if (!newPassword.equals(confirmPassword)) {
            throw new IllegalArgumentException("Passwords do not match");
        }

        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Invalid reset link"));

        if (!resetToken.isUsable()) {
            throw new IllegalArgumentException("Reset link is expired or already used");
        }

        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        resetToken.setUsedAt(Instant.now());
    }

    @Transactional
    public List<UserView> getAllUsers() {
        return getAllUsers(Pageable.ofSize(20)).getContent();
    }

    @Transactional(readOnly = true)
    public Page<UserView> getAllUsers(Pageable pageable) {
        Page<User> users = userRepository.findAllByOrderByUsernameAsc(pageable);
        Map<Long, Profile> profilesByUserId = profileRepository.findAllByUserIdsWithUser(
                users.getContent().stream().map(User::getId).toList()).stream()
                .collect(Collectors.toMap(profile -> profile.getUser().getId(), Function.identity()));

        return users.map(user -> toUserView(user, profilesByUserId.get(user.getId())));
    }

    @Transactional
    public UserView getUser(Long userId) {
        User user = userRepository.findByIdWithRole(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Profile profile = profileRepository.findByUserId(user.getId()).orElse(null);
        return toUserView(user, profile);
    }

    @Transactional(readOnly = true)
    public UserView getUserByUsername(String username) {
        User user = userRepository.findByUsernameWithRole(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        Profile profile = profileRepository.findByUserId(user.getId()).orElse(null);
        return toUserView(user, profile);
    }

    @Transactional(readOnly = true)
    public UserView getCurrentUser(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        return getUser(user.getId());
    }

    @Transactional
    public UserView updateSettings(String username, UpdateSettingsForm form) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        Profile profile = profileRepository.findByUserId(user.getId()).orElseGet(() -> {
            Profile p = new Profile();
            p.setUser(user);
            p.setVisibilityStatus(VisibilityStatus.PUBLIC);
            p.setDiveCount(0);
            return p;
        });
        profile.setProfileImageUrl(normalizeMediaUrl(form.getProfileImageUrl()));
        profile.setBio(blankToNull(form.getBio()));
        profile.setCity(blankToNull(form.getCity()));
        profile.setCountry(blankToNull(form.getCountry()));
        if (form.getDiveCount() != null && form.getDiveCount() >= 0)
            profile.setDiveCount(form.getDiveCount());
        if (form.getNewPassword() != null && !form.getNewPassword().isBlank()) {
            if (!form.getNewPassword().equals(form.getConfirmPassword()))
                throw new IllegalArgumentException("Passwords do not match");
            user.setPasswordHash(passwordEncoder.encode(form.getNewPassword()));
        }
        profileRepository.save(profile);
        return toUserView(user, profile);
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    @Transactional
    public UserView updateUser(Long userId, RegisterRequest request) {
        User user = userRepository.findByIdWithRole(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        user.setEmail(request.email());
        user.setUsername(request.username());
        user.setPasswordHash(passwordEncoder.encode(request.password()));

        Profile profile = profileRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Profile p = new Profile();
                    p.setUser(user);
                    p.setVisibilityStatus(VisibilityStatus.PUBLIC);
                    p.setDiveCount(0);
                    return p;
                });
        profile.setFirstName(request.firstName());
        profile.setLastName(request.lastName());
        profile.setCity(request.city());
        profile.setCountry(request.country());
        profileRepository.save(profile);

        return toUserView(user, profile);
    }

    @Transactional
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        user.setActive(false);
        user.setPasswordHash("DISABLED");
        userRepository.save(user);
    }

    private UserView toUserView(User user, Profile profile) {
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

    private String normalizeMediaUrl(String mediaUrl) {
        return mediaUrl == null || mediaUrl.isBlank() ? null : mediaStorageService.normalizeManagedUrl(mediaUrl);
    }
}
