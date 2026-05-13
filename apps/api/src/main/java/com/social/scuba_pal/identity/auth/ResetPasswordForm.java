package com.social.scuba_pal.identity.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResetPasswordForm {
    @NotBlank
    private String token = "";

    @NotBlank
    @Size(min = 6, max = 120)
    private String newPassword = "";

    @NotBlank
    private String confirmPassword = "";
}
