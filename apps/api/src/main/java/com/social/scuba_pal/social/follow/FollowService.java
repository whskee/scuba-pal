package com.social.scuba_pal.social.follow;

import com.social.scuba_pal.identity.profile.ProfileRepository;
import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.identity.user.UserRepository;
import com.social.scuba_pal.identity.user.UserView;
import com.social.scuba_pal.notification.NotificationService;
import com.social.scuba_pal.shared.exception.ResourceNotFoundException;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FollowService {
    private final UserRepository userRepository;
    private final UserFollowRepository userFollowRepository;
    private final ProfileRepository profileRepository;
    private final NotificationService notificationService;

    public FollowService(UserRepository userRepository,
                         UserFollowRepository userFollowRepository,
                         ProfileRepository profileRepository,
                         NotificationService notificationService) {
        this.userRepository = userRepository;
        this.userFollowRepository = userFollowRepository;
        this.profileRepository = profileRepository;
        this.notificationService = notificationService;
    }

    @Transactional
    public FollowSummaryView follow(String username, Long targetUserId) {
        User me = currentUser(username);
        User target = userRepository.findByIdWithRole(targetUserId).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (me.getId().equals(targetUserId)) throw new IllegalArgumentException("You cannot follow yourself.");
        if (!userFollowRepository.existsByFollowerIdAndFollowedId(me.getId(), targetUserId)) {
            UserFollow follow = new UserFollow();
            follow.setFollower(me);
            follow.setFollowed(target);
            userFollowRepository.save(follow);
            notificationService.createForUser(target, "New follower", me.getUsername() + " started following you.");
        }
        return getSummary(targetUserId, username);
    }

    @Transactional
    public FollowSummaryView unfollow(String username, Long targetUserId) {
        User me = currentUser(username);
        userFollowRepository.findByFollowerIdAndFollowedId(me.getId(), targetUserId).ifPresent(userFollowRepository::delete);
        return getSummary(targetUserId, username);
    }

    @Transactional(readOnly = true)
    public FollowSummaryView getSummary(Long targetUserId, String currentUsername) {
        return getSummary(targetUserId, currentUsername, Pageable.ofSize(10));
    }

    @Transactional(readOnly = true)
    public FollowSummaryView getSummary(Long targetUserId, String currentUsername, Pageable pageable) {
        User current = currentUsername == null ? null : currentUser(currentUsername);
        boolean follows = current != null && userFollowRepository.existsByFollowerIdAndFollowedId(current.getId(), targetUserId);
        return new FollowSummaryView(
                userFollowRepository.countByFollowerId(targetUserId),
                userFollowRepository.countByFollowedId(targetUserId),
                follows,
                userFollowRepository.findFollowing(targetUserId, pageable).map(uf -> toView(uf.getFollowed())).getContent(),
                userFollowRepository.findFollowers(targetUserId, pageable).map(uf -> toView(uf.getFollower())).getContent()
        );
    }

    @Transactional(readOnly = true)
    public Page<UserView> getFollowing(Long userId, Pageable pageable) {
        userRepository.findByIdWithRole(userId).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return userFollowRepository.findFollowing(userId, pageable).map(uf -> toView(uf.getFollowed()));
    }

    @Transactional(readOnly = true)
    public Page<UserView> getFollowers(Long userId, Pageable pageable) {
        userRepository.findByIdWithRole(userId).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return userFollowRepository.findFollowers(userId, pageable).map(uf -> toView(uf.getFollower()));
    }

    private User currentUser(String username) {
        return userRepository.findByUsername(username).orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private UserView toView(User user) {
        var profile = profileRepository.findByUserId(user.getId()).orElse(null);
        return new UserView(user.getId(), user.getUsername(), user.getEmail(), user.getRole().getName(),
                profile != null ? profile.getCity() : null,
                profile != null ? profile.getCountry() : null,
                profile != null ? profile.getDiveCount() : 0,
                profile != null ? profile.getBio() : null,
                profile != null ? profile.getProfileImageUrl() : null);
    }
}
