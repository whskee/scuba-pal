package com.scubapal.identity.auth.passwordreset;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mail.MailSendException;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.scubapal.identity.auth.api.ResetPasswordRequest;
import com.scubapal.identity.auth.token.RefreshTokenRepository;
import com.scubapal.identity.auth.token.TokenHashing;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.shared.mail.EmailService;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class PasswordResetServiceTest {

    private UserRepository userRepository;
    private PasswordResetTokenRepository passwordResetTokenRepository;
    private RefreshTokenRepository refreshTokenRepository;
    private PasswordEncoder passwordEncoder;
    private EmailService emailService;
    private PasswordResetService passwordResetService;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        passwordResetTokenRepository = mock(PasswordResetTokenRepository.class);
        refreshTokenRepository = mock(RefreshTokenRepository.class);
        passwordEncoder = mock(PasswordEncoder.class);
        emailService = mock(EmailService.class);
        passwordResetService = new PasswordResetService(
                userRepository,
                passwordResetTokenRepository,
                refreshTokenRepository,
                passwordEncoder,
                emailService,
                "http://localhost:8080/"
        );
    }

    @Test
    void blankPasswordResetLookupDoesNothing() {
        passwordResetService.sendPasswordResetLink("   ");

        verifyNoInteractions(userRepository, passwordResetTokenRepository, emailService);
    }

    @Test
    void sendsResetLinkForEmailLookup() {
        User user = user("dana@example.com", "dana");
        when(userRepository.findByEmailIgnoreCase("dana@example.com")).thenReturn(Optional.of(user));
        when(passwordResetTokenRepository.markUnusedTokensUsedForUser(any(), any())).thenReturn(0);
        when(passwordResetTokenRepository.save(any(PasswordResetToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        passwordResetService.sendPasswordResetLink(" dana@example.com ");

        ArgumentCaptor<PasswordResetToken> tokenCaptor = ArgumentCaptor.forClass(PasswordResetToken.class);
        verify(passwordResetTokenRepository).save(tokenCaptor.capture());
        assertEquals(user, tokenCaptor.getValue().getUser());
        assertTrue(tokenCaptor.getValue().isUsable(Instant.now()));
        assertEquals(64, tokenCaptor.getValue().getToken().length());

        ArgumentCaptor<String> linkCaptor = ArgumentCaptor.forClass(String.class);
        verify(emailService).sendPasswordResetEmail(eq("dana@example.com"), eq("dana"), linkCaptor.capture());
        assertTrue(linkCaptor.getValue().startsWith("http://localhost:8080/reset-password?token="));
        assertNotEquals(
                tokenCaptor.getValue().getToken(),
                linkCaptor.getValue().substring("http://localhost:8080/reset-password?token=".length()));
    }

    @Test
    void mailFailureDoesNotPreventTokenCreation() {
        User user = user("dana@example.com", "dana");
        when(userRepository.findByEmailIgnoreCase("dana@example.com")).thenReturn(Optional.of(user));
        when(passwordResetTokenRepository.markUnusedTokensUsedForUser(any(), any())).thenReturn(0);
        when(passwordResetTokenRepository.save(any(PasswordResetToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        org.mockito.Mockito.doThrow(new MailSendException("smtp unavailable"))
                .when(emailService)
                .sendPasswordResetEmail(any(), any(), any());

        passwordResetService.sendPasswordResetLink("dana@example.com");

        verify(passwordResetTokenRepository).save(any(PasswordResetToken.class));
        verify(userRepository, never()).findByUsernameIgnoreCase("dana@example.com");
    }

    @Test
    void resetPasswordRevokesActiveRefreshTokens() {
        User user = user("dana@example.com", "dana");
        user.setId(42L);
        PasswordResetToken resetToken = new PasswordResetToken();
        resetToken.setUser(user);
        resetToken.setToken(TokenHashing.sha256("reset-token"));
        resetToken.setExpiresAt(Instant.now().plusSeconds(3600));

        when(passwordResetTokenRepository.findByTokenForUpdate(TokenHashing.sha256("reset-token")))
                .thenReturn(Optional.of(resetToken));
        when(passwordEncoder.encode("newPassword123!")).thenReturn("new-hash");

        passwordResetService.resetPassword(new ResetPasswordRequest("reset-token", "newPassword123!", "newPassword123!"));

        assertEquals("new-hash", user.getPasswordHash());
        assertTrue(resetToken.getUsedAt() != null);
        verify(refreshTokenRepository).revokeActiveTokensForUser(eq(42L), any(), eq(null), eq("password-reset"));
    }

    private User user(String email, String username) {
        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setPasswordHash("hash");
        user.setActive(true);
        return user;
    }
}
