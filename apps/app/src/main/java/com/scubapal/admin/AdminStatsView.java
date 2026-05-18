package com.scubapal.admin;

public record AdminStatsView(
        long users,
        long posts,
        long locations,
        long shops,
        long notifications
) {
}
