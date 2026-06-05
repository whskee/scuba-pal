package com.scubapal.identity.auth.api;

import java.time.Instant;

import com.scubapal.identity.user.CurrentUserView;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        Instant expiresAt,
        CurrentUserView user
) {
    public AuthResponse(String accessToken, String refreshToken, Instant expiresAt, CurrentUserView user) {
        this(accessToken, refreshToken, "Bearer", expiresAt, user);
    }
}
