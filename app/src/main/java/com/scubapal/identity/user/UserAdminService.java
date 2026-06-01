package com.scubapal.identity.user;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.identity.role.Role;
import com.scubapal.identity.role.RoleNames;
import com.scubapal.identity.role.RoleRepository;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.shared.exception.ResourceNotFoundException;

import java.util.Locale;

@Service
@Transactional(readOnly = true)
public class UserAdminService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProfileRepository profileRepository;
    private final PasswordEncoder passwordEncoder;
    private final IdentityMapper identityMapper;
    private final IdentityQueryService identityQueryService;

    public UserAdminService(UserRepository userRepository,
                            RoleRepository roleRepository,
                            ProfileRepository profileRepository,
                            PasswordEncoder passwordEncoder,
                            IdentityMapper identityMapper,
                            IdentityQueryService identityQueryService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.profileRepository = profileRepository;
        this.passwordEncoder = passwordEncoder;
        this.identityMapper = identityMapper;
        this.identityQueryService = identityQueryService;
    }

    @PreAuthorize("hasRole('ADMIN')")
    public Page<AdminUserView> list(Pageable pageable) {
        return identityQueryService.findUsers(pageable);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public AdminUserView get(Long userId) {
        return identityQueryService.getUser(userId);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public AdminUserView create(AdminCreateUserRequest request) {
        String email = normalizeEmail(request.email());
        String username = normalizeUsername(request.username());
        ensureEmailAvailable(email);
        ensureUsernameAvailable(username);

        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setRole(resolveRole(request.role()));
        user.setActive(request.active() == null || request.active());
        User saved = saveUser(user);

        Profile profile = defaultProfile(saved);
        profile.setFirstName(blankToNull(request.firstName()));
        profile.setLastName(blankToNull(request.lastName()));
        profile.setCity(blankToNull(request.city()));
        profile.setCountry(blankToNull(request.country()));
        profileRepository.save(profile);
        return identityMapper.toAdminUserView(saved, profile);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public AdminUserView update(Long userId, UpdateUserRequest request) {
        User user = userRepository.findByIdWithRole(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        if (request.email() != null) {
            String email = normalizeEmail(request.email());
            userRepository.findByEmailIgnoreCase(email)
                    .filter(existing -> !existing.getId().equals(userId))
                    .ifPresent(existing -> {
                        throw new IllegalArgumentException("Email already in use");
                    });
            user.setEmail(email);
        }
        if (request.username() != null) {
            String username = normalizeUsername(request.username());
            userRepository.findByUsernameIgnoreCase(username)
                    .filter(existing -> !existing.getId().equals(userId))
                    .ifPresent(existing -> {
                        throw new IllegalArgumentException("Username already in use");
                    });
            user.setUsername(username);
        }
        if (request.active() != null) {
            user.setActive(request.active());
        }
        if (request.role() != null && !request.role().isBlank()) {
            user.setRole(resolveRole(request.role()));
        }

        Profile profile = profileRepository.findByUserId(userId).orElseGet(() -> defaultProfile(user));
        if (request.firstName() != null) {
            profile.setFirstName(blankToNull(request.firstName()));
        }
        if (request.lastName() != null) {
            profile.setLastName(blankToNull(request.lastName()));
        }
        if (request.city() != null) {
            profile.setCity(blankToNull(request.city()));
        }
        if (request.country() != null) {
            profile.setCountry(blankToNull(request.country()));
        }
        profileRepository.save(profile);
        return identityMapper.toAdminUserView(user, profile);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void deactivate(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        user.setActive(false);
    }

    private Profile defaultProfile(User user) {
        Profile profile = new Profile();
        profile.setUser(user);
        profile.setVisibilityStatus(VisibilityStatus.PUBLIC);
        profile.setDiveCount(0);
        return profile;
    }

    private Role resolveRole(String requestedRole) {
        String roleName = requestedRole == null || requestedRole.isBlank()
                ? RoleNames.USER
                : requestedRole.trim().toUpperCase(Locale.ROOT);
        return roleRepository.findByName(roleName)
                .orElseThrow(() -> new ResourceNotFoundException("Role not found: " + roleName));
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

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
