package com.scubapal.identity.user;

import com.scubapal.shared.domain.address.Address;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Embeddable
public class UserInfo {
    private String firstName;
    private String lastName;
    private String displayName;
    private String avatarUrl;
    private Gender gender;
    private String email;
    private String phoneNumber;
    private Address address;
}
