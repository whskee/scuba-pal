package com.scubapal.identity.auth;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.scubapal.identity.user.CurrentUserView;
import com.scubapal.shared.MessageResponse;

import java.util.Map;

@Tag(name = "Authentication", description = "Endpoints for user registration, login, and password management.")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final PasswordResetService passwordResetService;
    private final AuthenticationManager authenticationManager;

    public AuthController(AuthService authService,
                          PasswordResetService passwordResetService,
                          AuthenticationManager authenticationManager) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
        this.authenticationManager = authenticationManager;
    }

    @GetMapping("/username-available")
    public Map<String, Boolean> usernameAvailable(@RequestParam String username) {
        return Map.of("available", authService.isUsernameAvailable(username));
    }

    @PostMapping("/register")
    public ResponseEntity<CurrentUserView> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<CurrentUserView> login(@Valid @RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );
        return ResponseEntity.ok(authService.recordSuccessfulLogin(request.username()));
    }

    @PostMapping("/forgot-password")
    public MessageResponse forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        passwordResetService.sendPasswordResetLink(request.emailOrUsername());
        return new MessageResponse("If that account exists, a password reset link has been sent.");
    }

    @PostMapping("/reset-password")
    public MessageResponse resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        passwordResetService.resetPassword(request);
        return new MessageResponse("Password reset successfully.");
    }

    @PostMapping("/logout")
    public MessageResponse logout() {
        return new MessageResponse("For browser users, submit POST /logout. For API basic auth, forget the client credentials.");
    }
}
