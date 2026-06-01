package com.scubapal.admin;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.scubapal.social.post.FeedPostView;
import com.scubapal.social.post.PostService;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService adminService;
    private final PostService postService;

    public AdminController(AdminService adminService, PostService postService) {
        this.adminService = adminService;
        this.postService = postService;
    }

    @GetMapping("/stats")
    public AdminStatsView stats() {
        return adminService.getStats();
    }

    @GetMapping("/posts")
    public List<FeedPostView> posts() {
        return postService.getPublicFeed();
    }
}
