package com.scubapal.dive.shop;

import java.math.BigDecimal;

public record DiveShopResponse(
        Long shopId,
        String shopName,
        String description,
        String phoneNumber,
        String email,
        String websiteUrl,
        String imageUrl,
        String streetAddress,
        String city,
        String state,
        String country,
        BigDecimal latitude,
        BigDecimal longitude,
        Long locationId,
        String locationName
) {
}
