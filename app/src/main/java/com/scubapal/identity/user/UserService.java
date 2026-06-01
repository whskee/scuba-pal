package com.scubapal.identity.user;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.auth.AuthService;
import com.scubapal.identity.auth.LoginRequest;
import com.scubapal.identity.auth.PasswordResetService;
import com.scubapal.identity.auth.RegisterRequest;
import com.scubapal.identity.auth.ResetPasswordRequest;

@Service
@Transactional(readOnly = true)
public class UserService {

    private final AuthService authService;
    private final PasswordResetService passwordResetService;
    private final CurrentUserService currentUserService;
    private final UserAdminService userAdminService;
    private final IdentityQueryService identityQueryService;

    public UserService(AuthService authService,
                       PasswordResetService passwordResetService,
                       CurrentUserService currentUserService,
                       UserAdminService userAdminService,
                       IdentityQueryService identityQueryService) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
        this.currentUserService = currentUserService;
        this.userAdminService = userAdminService;
        this.identityQueryService = identityQueryService;
    }

    public boolean isUsernameAvailable(String username) {
        return authService.isUsernameAvailable(username);
    }

    @Transactional
    public UserView register(RegisterRequest request) {
        return authService.register(request);
    }

    @Transactional
    public UserView login(LoginRequest request) {
        return authService.recordSuccessfulLogin(request.username());
    }

    @Transactional
    public void sendPasswordResetLink(String emailOrUsername) {
        passwordResetService.sendPasswordResetLink(emailOrUsername);
    }

    public boolean isPasswordResetTokenUsable(String token) {
        return passwordResetService.isPasswordResetTokenUsable(token);
    }

    @Transactional
    public void resetPassword(String token, String newPassword, String confirmPassword) {
        passwordResetService.resetPassword(new ResetPasswordRequest(token, newPassword, confirmPassword));
    }

    public List<UserView> getAllUsers() {
        return getAllUsers(Pageable.ofSize(20)).getContent();
    }

    public Page<UserView> getAllUsers(Pageable pageable) {
        return identityQueryService.findUsers(pageable);
    }

    public Page<UserView> getUsersByCity(String city, Pageable pageable) {
        return identityQueryService.findUsersByCity(city, pageable);
    }

    public UserView getUser(Long userId) {
        return identityQueryService.getUser(userId);
    }

    public UserView getUserByUsername(String username) {
        return identityQueryService.getUserByUsername(username);
    }

    public UserView getCurrentUser(String username) {
        return currentUserService.getCurrentUser(username);
    }

    @Transactional
    public UserView updateSettings(String username, UpdateSettingsForm form) {
        return currentUserService.updateSettings(username, form);
    }

    @Transactional
    public UserView updateUser(Long userId, UpdateUserRequest request) {
        return userAdminService.update(userId, request);
    }

    @Transactional
    public void deleteUser(Long userId) {
        userAdminService.deactivate(userId);
    }
}
