package com.scubapal.dive.shop;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class DiveShopPageController {

    private final DiveShopService diveShopService;

    public DiveShopPageController(DiveShopService diveShopService) {
        this.diveShopService = diveShopService;
    }

    @GetMapping("/shops")
    public String shops(@RequestParam(required = false) String q,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "12") int size,
                        Model model) {
        var shopPage = diveShopService.search(q, pageable(page, size));
        model.addAttribute("q", q);
        model.addAttribute("shopPage", shopPage);
        model.addAttribute("shops", shopPage.getContent());
        return "dive/shops";
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50));
    }
}
