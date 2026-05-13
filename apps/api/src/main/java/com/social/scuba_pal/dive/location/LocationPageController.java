package com.social.scuba_pal.dive.location;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LocationPageController {
    private final LocationService locationService;

    public LocationPageController(LocationService locationService) {
        this.locationService = locationService;
    }

    @GetMapping("/locations")
    public String locations(@RequestParam(required = false) String city,
                            @RequestParam(defaultValue = "0") int page,
                            @RequestParam(defaultValue = "12") int size,
                            Model model) {
        var locationPage = locationService.getLocations(city, pageable(page, size));
        model.addAttribute("city", city);
        model.addAttribute("locationPage", locationPage);
        model.addAttribute("locations", locationPage.getContent());
        return "dive/locations";
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50), Sort.by("popularityScore").descending());
    }
}
