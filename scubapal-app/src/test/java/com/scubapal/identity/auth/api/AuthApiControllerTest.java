package com.scubapal.identity.auth.api;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.scubapal.identity.auth.AuthService;
import com.scubapal.identity.auth.passwordreset.PasswordResetService;
import com.scubapal.identity.auth.token.JwtTokenService;
import com.scubapal.identity.user.CurrentUserView;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthApiControllerTest {

    @Mock AuthService authService;
    @Mock PasswordResetService passwordResetService;
    @Mock AuthenticationManager authenticationManager;
    @Mock JwtTokenService jwtTokenService;
    @InjectMocks AuthApiController authController;

    @Test
    void keepsApiAuthRouteMappingsStable() {
        RequestMapping controllerMapping = AuthApiController.class.getAnnotation(RequestMapping.class);
        Set<String> postRoutes = Arrays.stream(AuthApiController.class.getDeclaredMethods())
                .filter(method -> method.isAnnotationPresent(PostMapping.class))
                .flatMap(method -> Arrays.stream(method.getAnnotation(PostMapping.class).value()))
                .collect(Collectors.toSet());
        Set<String> getRoutes = Arrays.stream(AuthApiController.class.getDeclaredMethods())
                .filter(method -> method.isAnnotationPresent(GetMapping.class))
                .flatMap(method -> Arrays.stream(method.getAnnotation(GetMapping.class).value()))
                .collect(Collectors.toSet());

        assertArrayEquals(new String[] {"/api/auth"}, controllerMapping.value());
        assertEquals(Set.of("/register", "/login", "/refresh", "/forgot-password", "/reset-password", "/logout"), postRoutes);
        assertEquals(Set.of("/username-available"), getRoutes);
    }

    @Test
    void registerCreatesUserAndReturnsCreated() {
        RegisterRequest request = new RegisterRequest("dana@example.com", "dana", "Password123!", "Dana", "Diver", "Phoenix", "USA");
        CurrentUserView view = new CurrentUserView(1L, "dana", "Dana", "Diver", "dana@example.com", "USER", "Phoenix", "USA", 0, null, null);
        AuthResponse authResponse = new AuthResponse("access", "refresh", java.time.Instant.now().plusSeconds(900), view);
        when(authService.register(request)).thenReturn(view);
        when(jwtTokenService.issueTokens(eq("dana"), any())).thenReturn(authResponse);

        var response = authController.register(request, new MockHttpServletRequest());

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertEquals(authResponse, response.getBody());
        verify(authService).register(request);
        verify(jwtTokenService).issueTokens(eq("dana"), any());
    }

    @Test
    void loginAuthenticatesBeforeReturningJwtTokens() {
        LoginRequest request = new LoginRequest("dana", "Password123!");
        CurrentUserView view = new CurrentUserView(1L, "dana", "Dana", "Diver", "dana@example.com", "USER", null, null, 0, null, null);
        AuthResponse authResponse = new AuthResponse("access", "refresh", java.time.Instant.now().plusSeconds(900), view);
        when(authService.recordSuccessfulLogin(request.username())).thenReturn(view);
        when(jwtTokenService.issueTokens(eq("dana"), any())).thenReturn(authResponse);

        var response = authController.login(request, new MockHttpServletRequest());

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(authResponse, response.getBody());
        verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(authService).recordSuccessfulLogin(request.username());
        verify(jwtTokenService).issueTokens(eq("dana"), any());
    }

    @Test
    void refreshRotatesRefreshToken() {
        CurrentUserView view = new CurrentUserView(1L, "dana", "Dana", "Diver", "dana@example.com", "USER", null, null, 0, null, null);
        AuthResponse authResponse = new AuthResponse("access2", "refresh2", java.time.Instant.now().plusSeconds(900), view);
        when(jwtTokenService.rotateRefreshToken(eq("refresh1"), any())).thenReturn(authResponse);

        AuthResponse response = authController.refresh(new RefreshTokenRequest("refresh1"), new MockHttpServletRequest());

        assertEquals(authResponse, response);
        verify(jwtTokenService).rotateRefreshToken(eq("refresh1"), any());
    }

    @Test
    void usernameAvailableDelegatesToAuthService() {
        when(authService.isUsernameAvailable("dana")).thenReturn(true);

        var response = authController.usernameAvailable("dana");

        assertTrue(response.get("available"));
    }

    @Test
    void forgotPasswordUsesTypedPayload() {
        authController.forgotPassword(new ForgotPasswordRequest("dana@example.com"));

        verify(passwordResetService).sendPasswordResetLink("dana@example.com");
    }

    @Test
    void logoutRevokesRefreshToken() {
        authController.logout(new RefreshTokenRequest("refresh1"), new MockHttpServletRequest());

        verify(jwtTokenService).revokeRefreshToken(eq("refresh1"), any());
    }
}
