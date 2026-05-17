package com.social.scuba_pal.shared.domain.address;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.Embedded;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class Address {
    @Embedded
    private Coordinates coordinates;

    @Column(length = AddressConstants.STREET_LENGTH)
    private String street;

    @Column(length = AddressConstants.CITY_LENGTH, nullable = false)
    private String city;

    @Column(length = AddressConstants.STATE_LENGTH)
    private String state;

    @Column(name = "zip_code", length = AddressConstants.ZIP_CODE_LENGTH)
    private String zipCode;

    @Column(name = "country_code", length = AddressConstants.COUNTRY_CODE_LENGTH, nullable = false)
    private String countryCode;
}