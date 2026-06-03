package com.scubapal.identity.auth.token;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.JwtEncoder;

import com.scubapal.identity.profile.ProfileService;
import com.scubapal.identity.user.IdentityMapper;
import com.scubapal.identity.user.UserRepository;

class JwtTokenServiceTest {

    private static final Clock FIXED_CLOCK = Clock.fixed(Instant.parse("2026-06-01T00:00:00Z"), ZoneOffset.UTC);

    @Test
    void reusingRevokedRefreshTokenFails() {
        RefreshTokenRepository refreshTokenRepository = mock(RefreshTokenRepository.class);
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setTokenHash(TokenHashing.sha256("refresh-token"));
        refreshToken.setExpiresAt(FIXED_CLOCK.instant().plus(Duration.ofDays(1)));
        refreshToken.setRevokedAt(FIXED_CLOCK.instant().minusSeconds(60));

        when(refreshTokenRepository.findByTokenHashForUpdate(TokenHashing.sha256("refresh-token")))
                .thenReturn(Optional.of(refreshToken));

        JwtTokenService tokenService = new JwtTokenService(
                mock(JwtEncoder.class),
                new JwtProperties("scuba-pal-test", "test-scuba-pal-jwt-secret-change-me-please-32b", Duration.ofMinutes(15), Duration.ofDays(30)),
                refreshTokenRepository,
                mock(UserRepository.class),
                mock(ProfileService.class),
                mock(IdentityMapper.class),
                FIXED_CLOCK,
                new SecureRandom());

        assertThrows(IllegalArgumentException.class, () -> tokenService.rotateRefreshToken("refresh-token", null));
        verify(refreshTokenRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }
}
