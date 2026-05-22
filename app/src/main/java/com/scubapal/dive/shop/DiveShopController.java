package com.scubapal.dive.shop;

import com.scubapal.shared.domain.address.Address;
import com.scubapal.shared.domain.address.Coordinates;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;

@Tag(name = "Dive Shops", description = "Endpoints for discovering dive shops")
@RestController
@RequestMapping("/api/shops")
public class DiveShopController {

    private final DiveShopRepository diveShopRepository;

    public DiveShopController(DiveShopRepository diveShopRepository) {
        this.diveShopRepository = diveShopRepository;
    }

    @GetMapping
    @Operation(summary = "List dive shops", description = "Returns dive shops, optionally filtered by shop name, city, state, country, or linked dive location.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Shop list returned")
    })
    public List<DiveShopResponse> getAll(@RequestParam(required = false) String q) {
        String term = normalize(q);
        return diveShopRepository.findAll(Sort.by(Sort.Direction.ASC, "shopName")).stream()
                .filter(shop -> matches(shop, term))
                .map(this::toResponse)
                .limit(50)
                .toList();
    }

    private boolean matches(DiveShop shop, String term) {
        if (term.isBlank()) {
            return true;
        }
        Address address = shop.getAddress();
        return contains(shop.getShopName(), term)
                || contains(shop.getDescription(), term)
                || contains(address != null ? address.getCity() : null, term)
                || contains(address != null ? address.getState() : null, term)
                || contains(address != null ? address.getCountry() : null, term)
                || contains(shop.getDiveLocation() != null ? shop.getDiveLocation().getLocationName() : null, term);
    }

    private boolean contains(String value, String term) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(term);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
    }

    private DiveShopResponse toResponse(DiveShop shop) {
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
