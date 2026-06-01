package com.scubapal.identity.user;

import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.shared.exception.ResourceNotFoundException;

@Service
@Transactional(readOnly = true)
public class IdentityQueryService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final IdentityMapper identityMapper;

    public IdentityQueryService(UserRepository userRepository,
                                ProfileRepository profileRepository,
                                IdentityMapper identityMapper) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.identityMapper = identityMapper;
    }

    public Page<UserView> findUsers(Pageable pageable) {
        Page<User> users = userRepository.findAllByOrderByUsernameAsc(pageable);
        if (users.isEmpty()) {
            return users.map(user -> identityMapper.toUserView(user, null));
        }
        Map<Long, Profile> profilesByUserId = profileRepository.findAllByUserIdsWithUser(
                        users.getContent().stream().map(User::getId).toList())
                .stream()
                .collect(Collectors.toMap(profile -> profile.getUser().getId(), Function.identity()));

        return users.map(user -> identityMapper.toUserView(user, profilesByUserId.get(user.getId())));
    }

    public Page<UserView> findUsersByCity(String city, Pageable pageable) {
        String normalizedCity = city == null ? "" : city.trim();
        if (normalizedCity.isBlank()) {
            return findUsers(pageable);
        }
        return profileRepository.findByCityContainingIgnoreCase(normalizedCity, pageable)
                .map(profile -> identityMapper.toUserView(profile.getUser(), profile));
    }

    public UserView getUser(Long userId) {
        User user = userRepository.findByIdWithRole(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Profile profile = profileRepository.findByUserId(user.getId()).orElse(null);
        return identityMapper.toUserView(user, profile);
    }

    public UserView getUserByUsername(String username) {
        User user = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        Profile profile = profileRepository.findByUserId(user.getId()).orElse(null);
        return identityMapper.toUserView(user, profile);
    }
}
