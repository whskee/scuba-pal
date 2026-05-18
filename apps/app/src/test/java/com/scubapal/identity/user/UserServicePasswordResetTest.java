package com.scubapal.identity.user;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mail.MailSendException;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.scubapal.identity.auth.PasswordResetToken;
import com.scubapal.identity.auth.PasswordResetTokenRepository;
import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.identity.role.RoleRepository;
import com.scubapal.media.MediaStorageService;
import com.scubapal.shared.mail.EmailService;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class UserServicePasswordResetTest {

    private UserRepository userRepository;
    private PasswordResetTokenRepository passwordResetTokenRepository;
    private EmailService emailService;
    private UserService userService;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        passwordResetTokenRepository = mock(PasswordResetTokenRepository.class);
        emailService = mock(EmailService.class);
        userService = new UserService(
                userRepository,
                mock(RoleRepository.class),
                mock(ProfileRepository.class),
                passwordResetTokenRepository,
                mock(PasswordEncoder.class),
                emailService,
                mock(MediaStorageService.class),
                "http://localhost:8080/"
        );
    }

    @Test
    void blankPasswordResetLookupDoesNothing() {
        userService.sendPasswordResetLink("   ");

        verifyNoInteractions(userRepository, passwordResetTokenRepository, emailService);
    }

    @Test
    void sendsResetLinkForEmailLookup() {
        User user = user("dana@example.com", "dana");
        when(userRepository.findByEmailIgnoreCase("dana@example.com")).thenReturn(Optional.of(user));
        when(passwordResetTokenRepository.save(any(PasswordResetToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        userService.sendPasswordResetLink(" dana@example.com ");

        ArgumentCaptor<PasswordResetToken> tokenCaptor = ArgumentCaptor.forClass(PasswordResetToken.class);
        verify(passwordResetTokenRepository).save(tokenCaptor.capture());
        assertEquals(user, tokenCaptor.getValue().getUser());
        assertTrue(tokenCaptor.getValue().isUsable());
        verify(emailService).sendPasswordResetEmail(
                "dana@example.com",
                "dana",
                "http://localhost:8080/reset-password?token=" + tokenCaptor.getValue().getToken()
        );
    }

    @Test
    void mailFailureDoesNotPreventTokenCreation() {
        User user = user("dana@example.com", "dana");
        when(userRepository.findByEmailIgnoreCase("dana@example.com")).thenReturn(Optional.of(user));
        when(passwordResetTokenRepository.save(any(PasswordResetToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        org.mockito.Mockito.doThrow(new MailSendException("smtp unavailable"))
                .when(emailService)
                .sendPasswordResetEmail(any(), any(), any());

        userService.sendPasswordResetLink("dana@example.com");

        verify(passwordResetTokenRepository).save(any(PasswordResetToken.class));
        verify(userRepository, never()).findByUsername("dana@example.com");
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
