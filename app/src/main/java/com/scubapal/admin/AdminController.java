package com.scubapal.admin;

import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.scubapal.shared.api.PageResponse;
import com.scubapal.social.post.FeedPostView;
import com.scubapal.social.post.PostService;

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
    public PageResponse<FeedPostView> posts(@RequestParam(defaultValue = "0") int page,
                                            @RequestParam(defaultValue = "20") int size) {
        return PageResponse.from(postService.getAllPostsForAdmin(PageRequest.of(
                Math.max(page, 0),
                Math.min(Math.max(size, 1), 100))));
    }
}
