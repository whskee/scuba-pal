package com.scubapal.identity.auth;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import com.scubapal.identity.user.UserService;
import com.scubapal.identity.user.UserView;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthControllerTest {

    @Mock UserService userService;
    @Mock AuthenticationManager authenticationManager;
    @InjectMocks AuthController authController;

    @Test
    void registerCreatesUserAndReturnsCreated() {
        RegisterRequest request = new RegisterRequest("dana@example.com", "dana", "Password123!", "Dana", "Diver", "Phoenix", "USA");
        UserView view = new UserView(1L, "dana", "Dana", "Diver", "dana@example.com", "user", "Phoenix", "USA", 0, null, null);
        when(userService.register(request)).thenReturn(view);

        var response = authController.register(request);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertEquals(view, response.getBody());
        verify(userService).register(request);
    }

    @Test
    void loginAuthenticatesBeforeReturningUser() {
        LoginRequest request = new LoginRequest("dana", "Password123!");
        UserView view = new UserView(1L, "dana", "Dana", "Diver", "dana@example.com", "user", null, null, 0, null, null);
        when(userService.login(request)).thenReturn(view);

        var response = authController.login(request);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(view, response.getBody());
        verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(userService).login(request);
    }

    @Test
    void usernameAvailableDelegatesToUserService() {
        when(userService.isUsernameAvailable("dana")).thenReturn(true);

        var response = authController.usernameAvailable("dana");

        assertTrue(response.get("available"));
    }

    @Test
    void forgotPasswordAcceptsEmailPayloadAlias() {
        authController.forgotPassword(Map.of("email", "dana@example.com"));

        verify(userService).sendPasswordResetLink("dana@example.com");
    }
}
