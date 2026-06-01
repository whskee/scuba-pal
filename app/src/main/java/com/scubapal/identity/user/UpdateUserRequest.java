package com.scubapal.identity.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public record UpdateUserRequest(
        @Email @Size(max = 320) String email,
        @Size(min = 3, max = 60) String username,
        @Size(max = 80) String firstName,
        @Size(max = 80) String lastName,
        @Size(max = 120) String city,
        @Size(max = 120) String country,
        Boolean active,
        @Size(max = 50) String role
) {
}
