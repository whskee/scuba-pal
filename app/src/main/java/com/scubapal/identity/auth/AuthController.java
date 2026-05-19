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

import com.scubapal.identity.user.UserService;
import com.scubapal.identity.user.UserView;
import com.scubapal.messaging.message.MessageResponse;

import java.util.Map;

@Tag(name = "Authentication", description = "Endpoints for user registration, login, and password management.")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;
    private final AuthenticationManager authenticationManager;

    public AuthController(UserService userService, AuthenticationManager authenticationManager) {
        this.userService = userService;
        this.authenticationManager = authenticationManager;
    }

    @GetMapping("/username-available")
    public Map<String, Boolean> usernameAvailable(@RequestParam String username) {
        return Map.of("available", userService.isUsernameAvailable(username));
    }

    @PostMapping("/register")
    public ResponseEntity<UserView> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<UserView> login(@Valid @RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );
        return ResponseEntity.ok(userService.login(request));
    }

    @PostMapping("/forgot-password")
    public MessageResponse forgotPassword(@RequestBody Map<String, String> body) {
        String emailOrUsername = body.getOrDefault("emailOrUsername", body.getOrDefault("email", ""));
        userService.sendPasswordResetLink(emailOrUsername);
        return new MessageResponse("If that account exists, a password reset link has been sent.");
    }

    @PostMapping("/reset-password")
    public MessageResponse resetPassword(@RequestBody Map<String, String> body) {
        userService.resetPassword(
                body.getOrDefault("token", ""),
                body.getOrDefault("newPassword", ""),
                body.getOrDefault("confirmPassword", "")
        );
        return new MessageResponse("Password reset successfully.");
    }

    @PostMapping("/logout")
    public MessageResponse logout() {
        return new MessageResponse("For browser users, submit POST /logout. For API basic auth, forget the client credentials.");
    }
}
