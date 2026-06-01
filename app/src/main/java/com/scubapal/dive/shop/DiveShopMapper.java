package com.scubapal.dive.shop;

import com.scubapal.shared.domain.address.Address;
import com.scubapal.shared.domain.address.Coordinates;

import java.math.BigDecimal;

import org.springframework.stereotype.Component;

@Component
public class DiveShopMapper {

    public DiveShopResponse toResponse(DiveShop shop) {
        Address address = shop.getAddress();
        Coordinates coordinates = shop.getCoordinates();
        BigDecimal latitude = coordinates != null ? coordinates.getLatitude() : null;
        BigDecimal longitude = coordinates != null ? coordinates.getLongitude() : null;

        return new DiveShopResponse(
                shop.getId(),
                shop.getShopName(),
                shop.getDescription(),
                shop.getPhoneNumber(),
                shop.getEmail(),
                shop.getWebsiteUrl(),
                shop.getImageUrl(),
                address != null ? address.getStreet() : null,
                address != null ? address.getCity() : null,
                address != null ? address.getState() : null,
                address != null ? address.getCountry() : null,
                latitude,
                longitude,
                shop.getDiveLocation() != null ? shop.getDiveLocation().getId() : null,
                shop.getDiveLocation() != null ? shop.getDiveLocation().getLocationName() : null
        );
    }
}
