package com.scubapal.identity.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ForgotPasswordRequest(
        @NotBlank @Size(max = 320) String emailOrUsername
) {
}
