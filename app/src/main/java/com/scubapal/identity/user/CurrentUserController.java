package com.scubapal.identity.user;

import java.security.Principal;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.scubapal.shared.MessageResponse;

@Tag(name = "Current User", description = "Endpoints for the authenticated user's account.")
@RestController
@RequestMapping("/api/me")
public class CurrentUserController {

    private final CurrentUserService currentUserService;

    public CurrentUserController(CurrentUserService currentUserService) {
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public UserView currentUser(Principal principal) {
        return currentUserService.getCurrentUser(principal.getName());
    }

    @PatchMapping("/settings")
    public UserView updateSettings(@Valid @RequestBody UpdateCurrentUserSettingsRequest request, Principal principal) {
        return currentUserService.updateSettings(principal.getName(), request);
    }

    @PatchMapping("/password")
    public MessageResponse changePassword(@Valid @RequestBody ChangePasswordRequest request, Principal principal) {
        currentUserService.changePassword(principal.getName(), request);
        return new MessageResponse("Password changed");
    }
}
