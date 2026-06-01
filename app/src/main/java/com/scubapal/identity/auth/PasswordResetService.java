package com.scubapal.identity.auth;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.shared.mail.EmailService;

@Service
@Transactional(readOnly = true)
public class PasswordResetService {

    private static final Logger log = LoggerFactory.getLogger(PasswordResetService.class);
    private static final int TOKEN_BYTES = 32;
    private static final long RESET_TTL_SECONDS = 3600;

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final SecureRandom secureRandom;
    private final Clock clock;
    private final String appBaseUrl;

    @Autowired
    public PasswordResetService(UserRepository userRepository,
                                PasswordResetTokenRepository passwordResetTokenRepository,
                                PasswordEncoder passwordEncoder,
                                EmailService emailService,
                                @Value("${app.base-url:http://localhost:8080}") String appBaseUrl) {
        this(userRepository, passwordResetTokenRepository, passwordEncoder, emailService, appBaseUrl, Clock.systemUTC(), new SecureRandom());
    }

    PasswordResetService(UserRepository userRepository,
                         PasswordResetTokenRepository passwordResetTokenRepository,
                         PasswordEncoder passwordEncoder,
                         EmailService emailService,
                         String appBaseUrl,
                         Clock clock,
                         SecureRandom secureRandom) {
        this.userRepository = userRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        this.appBaseUrl = appBaseUrl;
        this.clock = clock;
        this.secureRandom = secureRandom;
    }

    @Transactional
    public void sendPasswordResetLink(String emailOrUsername) {
        String lookup = emailOrUsername == null ? "" : emailOrUsername.trim();
        if (lookup.isBlank()) {
            return;
        }

        userRepository.findByEmailIgnoreCase(lookup)
                .or(() -> userRepository.findByUsernameIgnoreCase(lookup))
                .filter(User::isActive)
                .ifPresent(this::issueTokenAndSendEmail);
    }

    public boolean isPasswordResetTokenUsable(String rawToken) {
        String tokenHash = hashToken(rawToken);
        if (tokenHash.isBlank()) {
            return false;
        }
        Instant now = clock.instant();
        return passwordResetTokenRepository.findByToken(tokenHash)
                .map(token -> token.isUsable(now))
                .orElse(false);
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        if (!request.newPassword().equals(request.confirmPassword())) {
            throw new IllegalArgumentException("Passwords do not match");
        }

        String tokenHash = hashToken(request.token());
        if (tokenHash.isBlank()) {
            throw new IllegalArgumentException("Invalid reset link");
        }

        PasswordResetToken resetToken = passwordResetTokenRepository.findByTokenForUpdate(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("Invalid reset link"));

        Instant now = clock.instant();
        if (!resetToken.isUsable(now)) {
            throw new IllegalArgumentException("Reset link is expired or already used");
        }

        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        resetToken.setUsedAt(now);
    }

    private void issueTokenAndSendEmail(User user) {
        Instant now = clock.instant();
        passwordResetTokenRepository.markUnusedTokensUsedForUser(user.getId(), now);

        String rawToken = generateRawToken();
        PasswordResetToken resetToken = new PasswordResetToken();
        resetToken.setUser(user);
        resetToken.setToken(hashToken(rawToken));
        resetToken.setExpiresAt(now.plusSeconds(RESET_TTL_SECONDS));
        passwordResetTokenRepository.save(resetToken);

        String link = appBaseUrl.replaceAll("/+$", "") + "/reset-password?token=" + rawToken;
        try {
            emailService.sendPasswordResetEmail(user.getEmail(), user.getUsername(), link);
        } catch (MailException ex) {
            log.warn("Could not send password reset email to {}: {}", user.getEmail(), ex.getMessage());
        }
    }

    private String generateRawToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hashToken(String rawToken) {
        String token = rawToken == null ? "" : rawToken.trim();
        if (token.isBlank()) {
            return "";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is not available", ex);
        }
    }
}
