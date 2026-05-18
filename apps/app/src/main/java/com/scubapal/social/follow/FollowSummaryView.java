package com.scubapal.social.follow;

import java.util.List;

import com.scubapal.identity.user.UserView;

public record FollowSummaryView(
        long followingCount,
        long followerCount,
        boolean followedByCurrentUser,
        List<UserView> following,
        List<UserView> followers
) {}
