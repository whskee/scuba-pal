package com.social.scuba_pal.social.follow;

import com.social.scuba_pal.identity.profile.ProfileRepository;
import com.social.scuba_pal.identity.role.Role;
import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.identity.user.UserRepository;
import com.social.scuba_pal.notification.NotificationService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.PageImpl;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FollowServiceTest {

    @Mock UserRepository userRepository;
    @Mock UserFollowRepository userFollowRepository;
    @Mock ProfileRepository profileRepository;
    @Mock NotificationService notificationService;
    @InjectMocks FollowService followService;

    @Test
    void followCreatesRelationshipAndNotification() {
        User dana = user(1L, "dana");
        User kai = user(2L, "kai");
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(userRepository.findByIdWithRole(2L)).thenReturn(Optional.of(kai));
        when(userFollowRepository.existsByFollowerIdAndFollowedId(1L, 2L)).thenReturn(false, true);
        when(userFollowRepository.countByFollowerId(2L)).thenReturn(0L);
        when(userFollowRepository.countByFollowedId(2L)).thenReturn(1L);
        when(userFollowRepository.findFollowing(eq(2L), any())).thenReturn(new PageImpl<>(List.of()));
        when(userFollowRepository.findFollowers(eq(2L), any())).thenReturn(new PageImpl<>(List.of()));

        FollowSummaryView summary = followService.follow("dana", 2L);

        assertTrue(summary.followedByCurrentUser());
        assertEquals(1, summary.followerCount());
        verify(userFollowRepository).save(any(UserFollow.class));
        verify(notificationService).createForUser(kai, "New follower", "dana started following you.");
    }

    @Test
    void followIsIdempotentAndDoesNotDuplicateNotification() {
        User dana = user(1L, "dana");
        User kai = user(2L, "kai");
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(userRepository.findByIdWithRole(2L)).thenReturn(Optional.of(kai));
        when(userFollowRepository.existsByFollowerIdAndFollowedId(1L, 2L)).thenReturn(true, true);
        when(userFollowRepository.findFollowing(eq(2L), any())).thenReturn(new PageImpl<>(List.of()));
        when(userFollowRepository.findFollowers(eq(2L), any())).thenReturn(new PageImpl<>(List.of()));

        followService.follow("dana", 2L);

        verify(userFollowRepository, never()).save(any());
        verify(notificationService, never()).createForUser(any(), any(), any());
    }

    @Test
    void unfollowDeletesExistingRelationship() {
        User dana = user(1L, "dana");
        User kai = user(2L, "kai");
        UserFollow follow = new UserFollow();
        follow.setFollower(dana);
        follow.setFollowed(kai);
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(userFollowRepository.findByFollowerIdAndFollowedId(1L, 2L)).thenReturn(Optional.of(follow));
        when(userFollowRepository.existsByFollowerIdAndFollowedId(1L, 2L)).thenReturn(false);
        when(userFollowRepository.findFollowing(eq(2L), any())).thenReturn(new PageImpl<>(List.of()));
        when(userFollowRepository.findFollowers(eq(2L), any())).thenReturn(new PageImpl<>(List.of()));

        FollowSummaryView summary = followService.unfollow("dana", 2L);

        assertFalse(summary.followedByCurrentUser());
        verify(userFollowRepository).delete(follow);
    }

    @Test
    void getFollowersReturnsMappedUserViews() {
        User dana = user(1L, "dana");
        User kai = user(2L, "kai");
        UserFollow relation = new UserFollow();
        relation.setFollower(kai);
        relation.setFollowed(dana);
        when(userRepository.findByIdWithRole(1L)).thenReturn(Optional.of(dana));
        when(userFollowRepository.findFollowers(1L, PageRequest.of(0, 20))).thenReturn(new PageImpl<>(List.of(relation)));

        var page = followService.getFollowers(1L, PageRequest.of(0, 20));

        assertEquals(1, page.getTotalElements());
        assertEquals("kai", page.getContent().get(0).username());
    }

    @Test
    void getFollowingReturnsMappedUserViews() {
        User dana = user(1L, "dana");
        User kai = user(2L, "kai");
        UserFollow relation = new UserFollow();
        relation.setFollower(dana);
        relation.setFollowed(kai);
        when(userRepository.findByIdWithRole(1L)).thenReturn(Optional.of(dana));
        when(userFollowRepository.findFollowing(1L, PageRequest.of(0, 20))).thenReturn(new PageImpl<>(List.of(relation)));

        var page = followService.getFollowing(1L, PageRequest.of(0, 20));

        assertEquals(1, page.getTotalElements());
        assertEquals("kai", page.getContent().get(0).username());
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
}
