package com.scubapal.identity.auth.web;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ForgotPasswordForm {
    @NotBlank
    @Size(max = 320)
    private String emailOrUsername = "";
}
