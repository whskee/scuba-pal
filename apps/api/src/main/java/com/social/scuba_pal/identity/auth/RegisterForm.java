package com.social.scuba_pal.identity.auth;

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
    @Size(min = 6, max = 120)
    private String password = "";

    private String firstName = "";
    private String lastName = "";
    private String city = "";
    private String country = "";

    public RegisterRequest toRegisterRequest() {
        return new RegisterRequest(email, username, password, firstName, lastName, city, country);
    }
}
