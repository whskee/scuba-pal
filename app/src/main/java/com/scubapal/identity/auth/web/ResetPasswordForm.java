package com.scubapal.identity.auth.web;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResetPasswordForm {
    @NotBlank
    @Size(max = 160)
    private String token = "";

    @NotBlank
    @Size(min = 12, max = 120)
    private String newPassword = "";

    @NotBlank
    @Size(max = 120)
    private String confirmPassword = "";
}
