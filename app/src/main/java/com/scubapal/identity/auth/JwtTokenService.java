package com.scubapal.identity.auth;

import java.security.SecureRandom;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.List;

import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileService;
import com.scubapal.identity.user.CurrentUserView;
import com.scubapal.identity.user.IdentityMapper;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.shared.exception.ResourceNotFoundException;

import jakarta.servlet.http.HttpServletRequest;

@Service
@Transactional(readOnly = true)
public class JwtTokenService {

    private static final int REFRESH_TOKEN_BYTES = 48;

    private final JwtEncoder jwtEncoder;
    private final JwtProperties jwtProperties;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserRepository userRepository;
    private final ProfileService profileService;
    private final IdentityMapper identityMapper;
    private final SecureRandom secureRandom;
    private final Clock clock;

    @Autowired
    public JwtTokenService(JwtEncoder jwtEncoder,
                           JwtProperties jwtProperties,
                           RefreshTokenRepository refreshTokenRepository,
                           UserRepository userRepository,
                           ProfileService profileService,
                           IdentityMapper identityMapper) {
        this(jwtEncoder, jwtProperties, refreshTokenRepository, userRepository, profileService, identityMapper,
                Clock.systemUTC(), new SecureRandom());
    }

    JwtTokenService(JwtEncoder jwtEncoder,
                    JwtProperties jwtProperties,
                    RefreshTokenRepository refreshTokenRepository,
                    UserRepository userRepository,
                    ProfileService profileService,
                    IdentityMapper identityMapper,
                    Clock clock,
                    SecureRandom secureRandom) {
        this.jwtEncoder = jwtEncoder;
        this.jwtProperties = jwtProperties;
        this.refreshTokenRepository = refreshTokenRepository;
        this.userRepository = userRepository;
        this.profileService = profileService;
        this.identityMapper = identityMapper;
        this.clock = clock;
        this.secureRandom = secureRandom;
    }

    @Transactional
    public AuthResponse issueTokens(String username, HttpServletRequest request) {
        User user = requireActiveUser(username);
        return issueTokens(user, currentUserView(user), request);
    }

    @Transactional
    public AuthResponse issueTokens(User user, CurrentUserView userView, HttpServletRequest request) {
        Instant now = clock.instant();
        Instant accessExpiresAt = now.plus(jwtProperties.accessTokenTtl());
        String accessToken = encodeAccessToken(user, now, accessExpiresAt);
        String refreshToken = createRefreshToken(user, now, clientIp(request));
        return new AuthResponse(accessToken, refreshToken, accessExpiresAt, userView);
    }

    @Transactional
    public AuthResponse rotateRefreshToken(String rawRefreshToken, HttpServletRequest request) {
        String tokenHash = TokenHashing.sha256(rawRefreshToken);
        if (tokenHash.isBlank()) {
            throw new IllegalArgumentException("Refresh token is required");
        }

        RefreshToken refreshToken = refreshTokenRepository.findByTokenHashForUpdate(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("Invalid refresh token"));
        Instant now = clock.instant();
        if (!refreshToken.isUsable(now)) {
            throw new IllegalArgumentException("Refresh token is expired or revoked");
        }

        User user = refreshToken.getUser();
        if (!user.isActive()) {
            throw new IllegalArgumentException("User account is disabled");
        }

        String clientIp = clientIp(request);
        refreshToken.setRevokedAt(now);
        refreshToken.setRevokedByIp(clientIp);
        String replacement = createRefreshToken(user, now, clientIp);
        refreshToken.setReplacedByTokenHash(TokenHashing.sha256(replacement));

        Instant accessExpiresAt = now.plus(jwtProperties.accessTokenTtl());
        return new AuthResponse(
                encodeAccessToken(user, now, accessExpiresAt),
                replacement,
                accessExpiresAt,
                currentUserView(user));
    }

    @Transactional
    public void revokeRefreshToken(String rawRefreshToken, HttpServletRequest request) {
        String tokenHash = TokenHashing.sha256(rawRefreshToken);
        if (tokenHash.isBlank()) {
            return;
        }
        refreshTokenRepository.findByTokenHashForUpdate(tokenHash).ifPresent(token -> {
            if (token.getRevokedAt() == null) {
                token.setRevokedAt(clock.instant());
                token.setRevokedByIp(clientIp(request));
            }
        });
    }

    @Transactional
    public void revokeAllRefreshTokens(String username, HttpServletRequest request) {
        User user = requireActiveUser(username);
        refreshTokenRepository.revokeActiveTokensForUser(user.getId(), clock.instant(), clientIp(request));
    }

    private String encodeAccessToken(User user, Instant issuedAt, Instant expiresAt) {
        String role = user.getRole().getName().toUpperCase();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer(jwtProperties.issuer())
                .issuedAt(issuedAt)
                .expiresAt(expiresAt)
                .subject(user.getUsername())
                .claim("uid", user.getId())
                .claim("roles", List.of(role))
                .build();
        return jwtEncoder.encode(JwtEncoderParameters.from(claims)).getTokenValue();
    }

    private String createRefreshToken(User user, Instant now, String clientIp) {
        String rawToken = generateRefreshToken();
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setTokenHash(TokenHashing.sha256(rawToken));
        refreshToken.setExpiresAt(now.plus(jwtProperties.refreshTokenTtl()));
        refreshToken.setCreatedByIp(clientIp);
        refreshTokenRepository.save(refreshToken);
        return rawToken;
    }

    private CurrentUserView currentUserView(User user) {
        Profile profile = profileService.findProfileEntityByUserId(user.getId()).orElse(null);
        return identityMapper.toCurrentUserView(user, profile);
    }

    private User requireActiveUser(String username) {
        User user = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (!user.isActive()) {
            throw new IllegalArgumentException("User account is disabled");
        }
        return user;
    }

    private String generateRefreshToken() {
        byte[] bytes = new byte[REFRESH_TOKEN_BYTES];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String clientIp(HttpServletRequest request) {
        if (request == null) {
            return null;
        }
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
