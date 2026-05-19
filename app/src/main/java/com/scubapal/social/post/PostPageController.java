package com.scubapal.social.post;

import jakarta.validation.Valid;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class PostPageController {
    private final PostService postService;

    public PostPageController(PostService postService) {
        this.postService = postService;
    }

    @GetMapping("/feed")
    public String feed(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "10") int size,
                       Model model,
                       Authentication auth) {
        var postPage = postService.getPublicFeed(pageable(page, size));
        model.addAttribute("postPage", postPage);
        model.addAttribute("posts", postPage.getContent());
        model.addAttribute("createPostForm", new CreatePostForm());
        model.addAttribute("loggedIn", loggedIn(auth));
        return "social/feed";
    }

    @PostMapping("/posts")
    public String createPost(@Valid @ModelAttribute CreatePostForm form, BindingResult br, Authentication auth, RedirectAttributes ra) {
        if (br.hasErrors()) {
            ra.addFlashAttribute("postError", "Post caption cannot be blank.");
            return "redirect:/feed";
        }
        postService.createPostForUsername(auth.getName(), form.getCaption(), form.getVisibilityStatus(), form.mediaUrls());
        ra.addFlashAttribute("postSuccess", "Your post is live.");
        return "redirect:/feed";
    }

    @GetMapping("/posts/{id}")
    public String postDetail(@PathVariable Long id, Model model, Authentication auth) {
        String username = loggedIn(auth) ? auth.getName() : null;
        model.addAttribute("post", postService.getPostDetail(id, username));
        model.addAttribute("loggedIn", username != null);
        return "social/post-detail";
    }

    @PostMapping("/posts/{id}/like")
    public String toggleLike(@PathVariable Long id, Authentication auth) {
        postService.toggleLike(id, auth.getName());
        return "redirect:/posts/" + id;
    }

    @PostMapping("/posts/{id}/comments")
    public String addComment(@PathVariable Long id, @RequestParam String commentText, Authentication auth, RedirectAttributes ra) {
        if (commentText == null || commentText.trim().isBlank()) {
            ra.addFlashAttribute("commentError", "Comment cannot be blank.");
            return "redirect:/posts/" + id;
        }
        postService.addComment(id, auth.getName(), commentText);
        return "redirect:/posts/" + id;
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50), Sort.by("createdAt").descending());
    }

    private boolean loggedIn(Authentication auth) {
        return auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName());
    }
}
