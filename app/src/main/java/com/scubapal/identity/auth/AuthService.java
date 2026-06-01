package com.scubapal.identity.auth;

import java.time.LocalDateTime;
import java.util.Locale;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.dao.DataIntegrityViolationException;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileService;
import com.scubapal.identity.role.Role;
import com.scubapal.identity.role.RoleNames;
import com.scubapal.identity.role.RoleRepository;
import com.scubapal.identity.user.IdentityMapper;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.identity.user.CurrentUserView;
import com.scubapal.shared.exception.ResourceNotFoundException;

@Service
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProfileService profileService;
    private final PasswordEncoder passwordEncoder;
    private final IdentityMapper identityMapper;

    public AuthService(UserRepository userRepository,
                       RoleRepository roleRepository,
                       ProfileService profileService,
                       PasswordEncoder passwordEncoder,
                       IdentityMapper identityMapper) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.profileService = profileService;
        this.passwordEncoder = passwordEncoder;
        this.identityMapper = identityMapper;
    }

    public boolean isUsernameAvailable(String username) {
        String normalized = normalizeUsername(username);
        return normalized.length() >= 3 && userRepository.findByUsernameIgnoreCase(normalized).isEmpty();
    }

    @Transactional
    public CurrentUserView register(RegisterRequest request) {
        String email = normalizeEmail(request.email());
        String username = normalizeUsername(request.username());
        ensureEmailAvailable(email);
        ensureUsernameAvailable(username);

        Role role = roleRepository.findByName(RoleNames.USER)
                .orElseThrow(() -> new ResourceNotFoundException("Default role not found"));

        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setRole(role);
        user.setActive(true);
        User savedUser = saveUser(user);

        Profile profile = profileService.createDefaultProfileForUser(
                savedUser,
                request.firstName(),
                request.lastName(),
                request.city(),
                request.country());

        return identityMapper.toCurrentUserView(savedUser, profile);
    }

    @Transactional
    public CurrentUserView recordSuccessfulLogin(String username) {
        User user = userRepository.findByUsernameIgnoreCase(normalizeUsername(username))
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (!user.isActive()) {
            throw new IllegalArgumentException("User account is disabled");
        }
        user.setLastLoginAt(LocalDateTime.now());
        Profile profile = profileService.findProfileEntityByUserId(user.getId()).orElse(null);
        return identityMapper.toCurrentUserView(user, profile);
    }

    private User saveUser(User user) {
        try {
            return userRepository.save(user);
        } catch (DataIntegrityViolationException ex) {
            throw new IllegalArgumentException("Email or username already in use", ex);
        }
    }

    private void ensureEmailAvailable(String email) {
        userRepository.findByEmailIgnoreCase(email).ifPresent(existing -> {
            throw new IllegalArgumentException("Email already in use");
        });
    }

    private void ensureUsernameAvailable(String username) {
        userRepository.findByUsernameIgnoreCase(username).ifPresent(existing -> {
            throw new IllegalArgumentException("Username already in use");
        });
    }

    private String normalizeEmail(String email) {
        return email == null ? "" : email.trim().toLowerCase();
    }

    private String normalizeUsername(String username) {
        return username == null ? "" : username.trim().toLowerCase(Locale.ROOT);
    }
}
