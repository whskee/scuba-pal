package com.social.scuba_pal.admin;

public record AdminStatsView(
        long users,
        long posts,
        long locations,
        long shops,
        long notifications
) {
}
