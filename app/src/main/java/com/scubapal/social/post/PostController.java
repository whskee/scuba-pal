package com.scubapal.social.post;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.scubapal.messaging.message.MessageResponse;
import com.scubapal.social.comment.CreateCommentRequest;

@Tag(name = "Posts", description = "Endpoints for creating, retrieving, updating, and deleting posts and comments")
@RestController
@RequestMapping("/api/posts")
public class PostController {

    private final PostService postService;

    public PostController(PostService postService) {
        this.postService = postService;
    }

    @PostMapping
    public ResponseEntity<FeedPostView> create(@Valid @RequestBody CreatePostRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(postService.createPost(request));
    }

    @PostMapping("/me")
    public ResponseEntity<FeedPostView> createForCurrentUser(@Valid @RequestBody CreateCurrentUserPostRequest request,
                                                             Authentication authentication) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(postService.createPostForUsername(
                        authentication.getName(),
                        request.caption(),
                        request.safeVisibilityStatus(),
                        request.mediaUrls()));
    }

    @GetMapping
    public Page<FeedPostView> getAll(@RequestParam(defaultValue = "0") int page,
                                     @RequestParam(defaultValue = "10") int size) {
        return postService.getPublicFeed(pageable(page, size));
    }

    @GetMapping("/users/{userId}")
    public Page<FeedPostView> getByUser(@PathVariable Long userId,
                                        @RequestParam(defaultValue = "0") int page,
                                        @RequestParam(defaultValue = "12") int size) {
        return postService.getPostsByUser(userId, pageable(page, size));
    }

    @GetMapping("/{id}")
    public PostDetailView getById(@PathVariable Long id, Authentication authentication) {
        String username = authentication == null ? null : authentication.getName();
        return postService.getPostDetail(id, username);
    }

    @PostMapping("/{id}/like")
    public PostDetailView like(@PathVariable Long id, Authentication authentication) {
        return postService.toggleLike(id, authentication.getName());
    }

    @PostMapping("/{id}/comments")
    public PostDetailView comment(@PathVariable Long id,
                                  @Valid @RequestBody CreateCommentRequest request,
                                  Authentication authentication) {
        return postService.addComment(id, authentication.getName(), request.commentText());
    }

    @PutMapping("/{id}")
    public FeedPostView update(@PathVariable Long id, @Valid @RequestBody UpdatePostRequest request, Authentication authentication) {
        return postService.updatePost(id, request, authentication.getName());
    }

    @DeleteMapping("/{id}")
    public MessageResponse delete(@PathVariable Long id, Authentication authentication) {
        postService.deletePost(id, authentication.getName());
        return new MessageResponse("Post deleted");
    }

    @DeleteMapping("/{postId}/comments/{commentId}")
    public MessageResponse deleteComment(@PathVariable Long postId, @PathVariable Long commentId, Authentication authentication) {
        postService.deleteComment(postId, commentId, authentication.getName());
        return new MessageResponse("Comment deleted");
    }

    @GetMapping("/search")
    public Page<FeedPostView> search(@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int size) {
        return postService.getPublicFeed(pageable(page, size));
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50), Sort.by("createdAt").descending());
    }
}
