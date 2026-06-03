package com.scubapal.identity.auth.api;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.scubapal.identity.auth.AuthService;
import com.scubapal.identity.auth.passwordreset.PasswordResetService;
import com.scubapal.identity.auth.token.JwtTokenService;
import com.scubapal.shared.MessageResponse;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Tag(name = "Authentication", description = "Endpoints for user registration, login, and password management.")
@Validated
@RestController
@RequestMapping("/api/auth")
public class AuthApiController {

    private final AuthService authService;
    private final PasswordResetService passwordResetService;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenService jwtTokenService;

    public AuthApiController(AuthService authService,
                             PasswordResetService passwordResetService,
                             AuthenticationManager authenticationManager,
                             JwtTokenService jwtTokenService) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
        this.authenticationManager = authenticationManager;
        this.jwtTokenService = jwtTokenService;
    }

    @GetMapping("/username-available")
    public Map<String, Boolean> usernameAvailable(@RequestParam @NotBlank @Size(max = 60) String username) {
        return Map.of("available", authService.isUsernameAvailable(username));
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request,
                                                 HttpServletRequest servletRequest) {
        var user = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(jwtTokenService.issueTokens(user.username(), servletRequest));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request,
                                              HttpServletRequest servletRequest) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );
        authService.recordSuccessfulLogin(request.username());
        return ResponseEntity.ok(jwtTokenService.issueTokens(request.username(), servletRequest));
    }

    @PostMapping("/refresh")
    public AuthResponse refresh(@Valid @RequestBody RefreshTokenRequest request,
                                HttpServletRequest servletRequest) {
        return jwtTokenService.rotateRefreshToken(request.refreshToken(), servletRequest);
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
    public MessageResponse logout(@Valid @RequestBody RefreshTokenRequest request,
                                  HttpServletRequest servletRequest) {
        jwtTokenService.revokeRefreshToken(request.refreshToken(), servletRequest);
        return new MessageResponse("Refresh token revoked.");
    }
}
