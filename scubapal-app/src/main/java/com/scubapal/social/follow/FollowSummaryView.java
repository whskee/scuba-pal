package com.scubapal.social.follow;

import java.util.List;

import com.scubapal.identity.user.PublicUserView;

public record FollowSummaryView(
        long followingCount,
        long followerCount,
        boolean followedByCurrentUser,
        List<PublicUserView> following,
        List<PublicUserView> followers
) {}
