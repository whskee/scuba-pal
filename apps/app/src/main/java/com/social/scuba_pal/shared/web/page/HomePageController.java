package com.social.scuba_pal.shared.web.page;

import com.social.scuba_pal.admin.AdminService;
import com.social.scuba_pal.dive.location.LocationService;
import com.social.scuba_pal.social.post.PostService;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

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
