package com.social.scuba_pal.identity.profile;

import com.social.scuba_pal.identity.user.UserService;
import com.social.scuba_pal.social.follow.FollowService;
import com.social.scuba_pal.social.post.PostService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class ProfilePageController {
    private final UserService userService;
    private final PostService postService;
    private final FollowService followService;

    public ProfilePageController(UserService userService, PostService postService, FollowService followService) {
        this.userService = userService;
        this.postService = postService;
        this.followService = followService;
    }

    @GetMapping("/buddies")
    public String buddies(@RequestParam(required = false) String city,
                          @RequestParam(defaultValue = "0") int page,
                          @RequestParam(defaultValue = "12") int size,
                          Model model) {
        var userPage = userService.getAllUsers(pageable(page, size));
        model.addAttribute("city", city);
        model.addAttribute("userPage", userPage);
        model.addAttribute("users", userPage.getContent());
        return "social/buddies";
    }

    @GetMapping("/divers")
    public String divers(@RequestParam(defaultValue = "0") int page,
                         @RequestParam(defaultValue = "12") int size,
                         Model model) {
        var userPage = userService.getAllUsers(pageable(page, size));
        model.addAttribute("userPage", userPage);
        model.addAttribute("users", userPage.getContent());
        return "social/divers";
    }

    @GetMapping("/profile/{id}")
    public String profile(@PathVariable Long id,
                          @RequestParam(defaultValue = "0") int page,
                          @RequestParam(defaultValue = "6") int size,
                          Model model,
                          Authentication auth) {
        String username = loggedIn(auth) ? auth.getName() : null;
        var posts = postService.getPostsByUser(id, PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 30)));
        model.addAttribute("user", userService.getUser(id));
        model.addAttribute("profile", userService.getUser(id));
        model.addAttribute("postPage", posts);
        model.addAttribute("posts", posts.getContent());
        model.addAttribute("followSummary", followService.getSummary(id, username, pageable(page, size)));
        return "social/profile";
    }

    @PostMapping("/profile/{id}/follow")
    public String followUser(@PathVariable Long id, Authentication auth) {
        followService.follow(auth.getName(), id);
        return "redirect:/profile/" + id;
    }

    @PostMapping("/profile/{id}/unfollow")
    public String unfollowUser(@PathVariable Long id, Authentication auth) {
        followService.unfollow(auth.getName(), id);
        return "redirect:/profile/" + id;
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50));
    }

    private boolean loggedIn(Authentication auth) {
        return auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName());
    }
}
