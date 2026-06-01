package com.scubapal.identity.auth;

import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.scubapal.identity.user.UserService;

@Controller
public class AuthPageController {
    private final UserService userService;

    public AuthPageController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/login")
    public String login() {
        return "auth/login";
    }

    @GetMapping("/forgot-password")
    public String forgotPassword(Model model) {
        if (!model.containsAttribute("forgotPasswordForm")) {
            model.addAttribute("forgotPasswordForm", new ForgotPasswordForm());
        }
        return "auth/forgot-password";
    }

    @PostMapping("/forgot-password")
    public String sendPasswordReset(@Valid @ModelAttribute ForgotPasswordForm form, BindingResult br, RedirectAttributes ra) {
        if (br.hasErrors()) {
            return "auth/forgot-password";
        }
        userService.sendPasswordResetLink(form.getEmailOrUsername());
        ra.addFlashAttribute("resetEmailSent", "If that account exists, a password reset link has been sent.");
        return "redirect:/forgot-password";
    }

    @GetMapping("/reset-password")
    public String resetPassword(@RequestParam String token, Model model) {
        ResetPasswordForm form = new ResetPasswordForm();
        form.setToken(token);
        model.addAttribute("resetPasswordForm", form);
        model.addAttribute("tokenUsable", userService.isPasswordResetTokenUsable(token));
        return "auth/reset-password";
    }

    @PostMapping("/reset-password")
    public String resetPasswordSubmit(@Valid @ModelAttribute ResetPasswordForm form, BindingResult br, RedirectAttributes ra, Model model) {
        if (br.hasErrors()) {
            model.addAttribute("tokenUsable", userService.isPasswordResetTokenUsable(form.getToken()));
            return "auth/reset-password";
        }
        try {
            userService.resetPassword(form.getToken(), form.getNewPassword(), form.getConfirmPassword());
        } catch (IllegalArgumentException ex) {
            br.reject("reset.failed", ex.getMessage());
            model.addAttribute("tokenUsable", false);
            return "auth/reset-password";
        }
        ra.addFlashAttribute("registrationSuccess", "Password reset. Log in with your new password.");
        return "redirect:/login";
    }

    @GetMapping("/register")
    public String register(Model model) {
        if (!model.containsAttribute("registerRequest")) {
            model.addAttribute("registerRequest", new RegisterForm());
        }
        return "auth/register";
    }

    @PostMapping("/register")
    public String registerUser(@Valid @ModelAttribute("registerRequest") RegisterForm request, BindingResult br, RedirectAttributes ra) {
        if (br.hasErrors()) {
            return "auth/register";
        }
        try {
            userService.register(request.toRegisterRequest());
        } catch (IllegalArgumentException ex) {
            br.reject("registration.failed", ex.getMessage());
            return "auth/register";
        }
        ra.addFlashAttribute("registrationSuccess", "Account created. Log in with your new credentials.");
        return "redirect:/login";
    }
}
