package com.social.scuba_pal.dive.location;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

import com.social.scuba_pal.shared.domain.AuditableEntity;

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

    private String city;
    private String state;
    private String country;

    private BigDecimal latitude;
    private BigDecimal longitude;

    @Column(name = "difficulty_level")
    private String difficultyLevel;

    @Column(name = "popularity_score", nullable = false)
    private Integer popularityScore = 0;
}
