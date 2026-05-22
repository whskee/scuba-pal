package com.scubapal.dive.location;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import com.scubapal.shared.domain.AuditableEntity;
import com.scubapal.shared.domain.address.Coordinates;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "dive_location_id"))
@Table(schema = "dive", name = "dive_locations")
public class DiveLocation extends AuditableEntity {

    @Column(name = "location_name", nullable = false)
    private String locationName;

    @Column(length = 600)
    private String description;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    private String city;
    private String state;
    private String country;
    // @Embedded
    // private Address address;

    @Embedded
    private Coordinates coordinates;

    @Column(name = "difficulty_level")
    private String difficultyLevel;

    @Column(name = "popularity_score", nullable = false)
    private Integer popularityScore = 0;
}
