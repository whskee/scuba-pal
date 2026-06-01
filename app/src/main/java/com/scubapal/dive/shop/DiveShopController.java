package com.scubapal.dive.shop;

import com.scubapal.shared.api.PageResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Dive Shops", description = "Endpoints for discovering dive shops")
@RestController
@RequestMapping("/api/shops")
public class DiveShopController {

    private final DiveShopService diveShopService;

    public DiveShopController(DiveShopService diveShopService) {
        this.diveShopService = diveShopService;
    }

    @GetMapping
    @Operation(summary = "List dive shops", description = "Returns paged dive shops, optionally filtered by shop name, city, state, country, or linked dive location.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Shop list returned")
    })
    public PageResponse<DiveShopResponse> getAll(@RequestParam(required = false) String q,
                                                 @RequestParam(defaultValue = "0") int page,
                                                 @RequestParam(defaultValue = "50") int size) {
        return PageResponse.from(diveShopService.search(q, PageRequest.of(
                Math.max(page, 0),
                Math.min(Math.max(size, 1), 100))));
    }
}
