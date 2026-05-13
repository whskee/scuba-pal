package com.social.scuba_pal.identity.profile;

import com.social.scuba_pal.identity.role.Role;
import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.identity.user.UserRepository;
import com.social.scuba_pal.shared.VisibilityStatus;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProfileServiceTest {

    @Mock
    ProfileRepository profileRepository;
    @Mock
    UserRepository userRepository;
    @InjectMocks
    ProfileService profileService;

    @Test
    void getByUserIdReturnsProfileForProfileAccess() {
        Profile profile = profile(user(1L, "dana"));
        when(profileRepository.findByUserId(1L)).thenReturn(Optional.of(profile));

        ProfileResponse result = profileService.getByUserId(1L);

        assertEquals("Phoenix", result.city());
        assertEquals(VisibilityStatus.PUBLIC, result.visibilityStatus());
    }

    @Test
    void createDefaultsVisibilityAndDiveCount() {
        User dana = user(1L, "dana");
        UpsertProfileRequest input = new UpsertProfileRequest(
                null,
                null,
                null,
                "Tempe",
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
        when(userRepository.findById(1L)).thenReturn(Optional.of(dana));
        when(profileRepository.findByUserId(1L)).thenReturn(Optional.empty());
        when(profileRepository.save(any(Profile.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ProfileResponse saved = profileService.create(1L, input);

        assertEquals(dana.getId(), saved.userId());
        assertEquals("Tempe", saved.city());
        assertEquals(VisibilityStatus.PUBLIC, saved.visibilityStatus());
        assertEquals(0, saved.diveCount());
    }

    @Test
    void updateKeepsExistingVisibilityAndDiveCountWhenInputOmitsThem() {
        Profile existing = profile(user(1L, "dana"));
        existing.setDiveCount(12);
        UpsertProfileRequest input = new UpsertProfileRequest(
                null,
                null,
                null,
                "Flagstaff",
                null,
                null,
                null,
                null,
                null,
                "Cold water diver",
                null
        );
        when(profileRepository.findByUserId(1L)).thenReturn(Optional.of(existing));
        when(profileRepository.save(existing)).thenReturn(existing);

        ProfileResponse updated = profileService.update(1L, input);

        assertEquals("Flagstaff", updated.city());
        assertEquals("Cold water diver", updated.bio());
        assertEquals(VisibilityStatus.PUBLIC, updated.visibilityStatus());
        assertEquals(12, updated.diveCount());
    }

    private static User user(Long id, String username) {
        Role role = new Role();
        role.setId(1L);
        role.setName("user");
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setEmail(username + "@example.com");
        user.setPasswordHash("hash");
        user.setRole(role);
        user.setActive(true);
        return user;
    }

    private static Profile profile(User user) {
        Profile profile = new Profile();
        profile.setId(1L);
        profile.setUser(user);
        profile.setCity("Phoenix");
        profile.setCountry("USA");
        profile.setVisibilityStatus(VisibilityStatus.PUBLIC);
        profile.setDiveCount(5);
        return profile;
    }
}
