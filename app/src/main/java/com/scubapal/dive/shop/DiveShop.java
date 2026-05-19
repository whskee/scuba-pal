package com.scubapal.dive.shop;

import com.scubapal.dive.location.DiveLocation;
import com.scubapal.shared.domain.AuditableEntity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "dive_shop_id"))
@Table(schema = "dive", name = "dive_shops")
public class DiveShop extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dive_location_id")
    private DiveLocation diveLocation;

    @Column(name = "shop_name", nullable = false)
    private String shopName;

    private String description;

    @Column(name = "phone_number")
    private String phoneNumber;

    private String email;

    @Column(name = "website_url")
    private String websiteUrl;

    @Column(name = "street_address")
    private String streetAddress;

    private String city;
    private String state;
    private String country;
}
