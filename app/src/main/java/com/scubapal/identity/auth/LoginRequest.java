package com.scubapal.identity.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LoginRequest(
        @NotBlank @Size(max = 320) String username,
        @NotBlank @Size(max = 120) String password
) {
}
