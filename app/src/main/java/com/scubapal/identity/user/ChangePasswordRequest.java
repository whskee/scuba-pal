package com.scubapal.identity.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangePasswordRequest(
        @NotBlank String currentPassword,
        @NotBlank @Size(min = 12, max = 120) String newPassword,
        @NotBlank @Size(max = 120) String confirmPassword
) {
}
