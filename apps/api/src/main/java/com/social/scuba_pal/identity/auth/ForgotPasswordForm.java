package com.social.scuba_pal.identity.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ForgotPasswordForm {
    @NotBlank
    private String emailOrUsername = "";
}
