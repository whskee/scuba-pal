package com.scubapal.identity.auth.api;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @Email @NotBlank @Size(max = 320) String email,
        @NotBlank @Size(min = 3, max = 60) String username,
        @NotBlank @Size(min = 12, max = 120) String password,
        @Size(max = 80) String firstName,
        @Size(max = 80) String lastName,
        @Size(max = 120) String city,
        @Size(max = 120) String country
) {
}
