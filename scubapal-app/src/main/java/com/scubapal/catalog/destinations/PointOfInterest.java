package com.scubapal.catalog.destinations;

import com.scubapal.shared.domain.address.Address;
import com.scubapal.shared.domain.address.Coordinates;

import jakarta.persistence.Embeddable;
import jakarta.persistence.Embedded;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class PointOfInterest {

    @Enumerated(EnumType.STRING)
    private PoiType type;

    private String name;
    private String description;
    private String websiteUrl;
    private String imageUrl;

    @Embedded
    private Coordinates coordinates;

    @Embedded
    private Address address;

}
