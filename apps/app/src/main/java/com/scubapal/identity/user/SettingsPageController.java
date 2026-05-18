package com.scubapal.identity.user;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class SettingsPageController {
    private final UserService userService;

    public SettingsPageController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/settings")
    public String settings(Model model, Authentication auth) {
        UserView current = userService.getCurrentUser(auth.getName());
        UpdateSettingsForm form = new UpdateSettingsForm();
        form.setProfileImageUrl(current.profileImageUrl());
        form.setBio(current.bio());
        form.setCity(current.city());
        form.setCountry(current.country());
        form.setDiveCount(current.diveCount());
        model.addAttribute("settingsForm", form);
        return "auth/settings";
    }

    @PostMapping("/settings")
    public String updateSettings(@Valid @ModelAttribute("settingsForm") UpdateSettingsForm form,
                                 BindingResult br,
                                 Authentication auth,
                                 RedirectAttributes ra) {
        if (br.hasErrors()) return "auth/settings";
        try {
            userService.updateSettings(auth.getName(), form);
        } catch (IllegalArgumentException ex) {
            br.reject("settings.failed", ex.getMessage());
            return "auth/settings";
        }
        ra.addFlashAttribute("settingsSuccess", "Settings updated.");
        return "redirect:/settings";
    }
}
