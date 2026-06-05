package com.scubapal.shared.web.page;

import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.scubapal.admin.AdminService;
import com.scubapal.dive.location.LocationService;
import com.scubapal.social.post.PostService;

@Controller
public class HomePageController {
    private final AdminService adminService;
    private final PostService postService;
    private final LocationService locationService;

    public HomePageController(AdminService adminService, PostService postService, LocationService locationService) {
        this.adminService = adminService;
        this.postService = postService;
        this.locationService = locationService;
    }

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("stats", adminService.getStats());
        model.addAttribute("posts", postService.getPublicFeed(Pageable.ofSize(3)).getContent());
        model.addAttribute("locations", locationService.getLocations(null, Pageable.ofSize(4)).getContent());
        return "index";
    }
}
