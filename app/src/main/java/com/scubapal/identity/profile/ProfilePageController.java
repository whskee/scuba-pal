package com.scubapal.identity.profile;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.scubapal.identity.user.UserService;
import com.scubapal.social.follow.FollowService;
import com.scubapal.social.post.PostService;

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
    public String buddies(
                          @RequestParam(required = false) String city,
                          @RequestParam(defaultValue = "0") int page,
                          @RequestParam(defaultValue = "12") int size,
                          Model model) {
        var userPage = userService.getUsersByCity(city, pageable(page, size));
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

    @GetMapping("/profile/{username}")
    public String profile(@PathVariable String username,
                          @RequestParam(defaultValue = "0") int page,
                          @RequestParam(defaultValue = "6") int size,
                          Model model,
                          Authentication auth) {
        var user = looksNumeric(username)
                ? userService.getUser(Long.valueOf(username))
                : userService.getUserByUsername(username);
        if (looksNumeric(username)) {
            return "redirect:/profile/" + user.username();
        }
        String currentUsername = loggedIn(auth) ? auth.getName() : null;
        var posts = postService.getPublicPostsByUser(user.id(),
                PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 30)));
        model.addAttribute("user", user);
        model.addAttribute("postPage", posts);
        model.addAttribute("posts", posts.getContent());
        model.addAttribute("followSummary", followService.getSummary(user.id(), currentUsername, pageable(page, size)));
        return "social/profile";
    }

    @PostMapping("/profile/{username}/follow")
    public String followUser(@PathVariable String username, Authentication auth) {
        var user = userService.getUserByUsername(username);
        followService.follow(auth.getName(), user.id());
        return "redirect:/profile/" + user.username();
    }

    @PostMapping("/profile/{username}/unfollow")
    public String unfollowUser(@PathVariable String username, Authentication auth) {
        var user = userService.getUserByUsername(username);
        followService.unfollow(auth.getName(), user.id());
        return "redirect:/profile/" + user.username();
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50));
    }

    private boolean loggedIn(Authentication auth) {
        return auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName());
    }

    private boolean looksNumeric(String value) {
        return value != null && value.matches("\\d+");
    }
}
