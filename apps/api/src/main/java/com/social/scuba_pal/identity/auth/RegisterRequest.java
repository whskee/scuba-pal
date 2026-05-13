package com.social.scuba_pal.identity.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @Email @NotBlank String email,
        @NotBlank @Size(min = 3, max = 60) String username,
        @NotBlank @Size(min = 6, max = 120) String password,
        String firstName,
        String lastName,
        String city,
        String country
) {
}
