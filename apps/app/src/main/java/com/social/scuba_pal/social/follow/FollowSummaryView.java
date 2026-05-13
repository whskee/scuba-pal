package com.social.scuba_pal.social.follow;

import java.util.List;

import com.social.scuba_pal.identity.user.UserView;

public record FollowSummaryView(
        long followingCount,
        long followerCount,
        boolean followedByCurrentUser,
        List<UserView> following,
        List<UserView> followers
) {}
