package com.scubapal.identity.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
        @NotBlank @Size(max = 160) String token,
        @NotBlank @Size(min = 12, max = 120) String newPassword,
        @NotBlank @Size(max = 120) String confirmPassword
) {
}
