package com.scubapal.identity.auth;

import java.time.Duration;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.security.jwt")
public record JwtProperties(
        String issuer,
        String secret,
        Duration accessTokenTtl,
        Duration refreshTokenTtl
) {
    public JwtProperties {
        if (issuer == null || issuer.isBlank()) {
            issuer = "scuba-pal";
        }
        if (accessTokenTtl == null) {
            accessTokenTtl = Duration.ofMinutes(15);
        }
        if (refreshTokenTtl == null) {
            refreshTokenTtl = Duration.ofDays(30);
        }
    }
}
