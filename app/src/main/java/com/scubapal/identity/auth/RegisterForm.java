package com.scubapal.identity.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterForm {

    @Email
    @NotBlank
    private String email = "";

    @NotBlank
    @Size(min = 3, max = 60)
    private String username = "";

    @NotBlank
    @Size(min = 12, max = 120)
    private String password = "";

    @NotBlank
    private String confirmPassword = "";

    @Size(max = 80)
    private String firstName = "";

    @Size(max = 80)
    private String lastName = "";

    @Size(max = 120)
    private String city = "";

    @Size(max = 120)
    private String country = "";

    public boolean passwordsMatch() {
        return password != null && password.equals(confirmPassword);
    }

    public RegisterRequest toRegisterRequest() {
        return new RegisterRequest(email, username, password, firstName, lastName, city, country);
    }
}
