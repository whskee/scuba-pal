package com.social.scuba_pal.identity.user;

import com.social.scuba_pal.shared.domain.Gender;
import com.social.scuba_pal.shared.domain.address.Address;

import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@Getter
@Setter
@NoArgsConstructor
@Embeddable
public class UserInfo {
    private String firstName;
    private String lastName;
    private Gender gender;
    private String email;
    private String phoneNumber;
    private Address address;
}
