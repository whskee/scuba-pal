package com.social.scuba_pal.social.follow;

import com.social.scuba_pal.identity.user.UserView;
import com.social.scuba_pal.shared.api.PageMetaResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Follows", description = "Endpoints for follow actions and read-only follow lists")
@RestController
@RequestMapping("/api/users")
public class FollowController {
    private final FollowService followService;

    public FollowController(FollowService followService) {
        this.followService = followService;
    }

    @PostMapping("/{userId}/follow")
    @Operation(summary = "Follow user", description = "Creates a follow relationship from the authenticated user to the target user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Follow summary returned"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Authentication required"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public FollowSummaryView follow(@PathVariable Long userId, Authentication authentication) {
        return followService.follow(authentication.getName(), userId);
    }

    @DeleteMapping("/{userId}/follow")
    @Operation(summary = "Unfollow user", description = "Removes a follow relationship for the authenticated user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Follow summary returned"),
            @ApiResponse(responseCode = "401", description = "Authentication required")
    })
    public FollowSummaryView unfollow(@PathVariable Long userId, Authentication authentication) {
        return followService.unfollow(authentication.getName(), userId);
    }


    @GetMapping("/{userId}/follow-summary")
    @Operation(summary = "Get follow summary", description = "Returns follower/following counts and whether the current user follows the target user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Follow summary returned"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public FollowSummaryView summary(@PathVariable Long userId, Authentication authentication) {
        String username = authentication == null ? null : authentication.getName();
        return followService.getSummary(userId, username);
    }

    @GetMapping("/{userId}/followers")
    @Operation(summary = "List followers", description = "Returns a read-only paged list of users following the target user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Follower list returned"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public UserListResponse followers(@PathVariable Long userId,
                                      @RequestParam(defaultValue = "0") int page,
                                      @RequestParam(defaultValue = "20") int size) {
        Page<UserView> result = followService.getFollowers(userId, pageable(page, size));
        return new UserListResponse(result.getContent(), toPageMeta(result));
    }

    @GetMapping("/{userId}/following")
    @Operation(summary = "List following", description = "Returns a read-only paged list of users followed by the target user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Following list returned"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public UserListResponse following(@PathVariable Long userId,
                                      @RequestParam(defaultValue = "0") int page,
                                      @RequestParam(defaultValue = "20") int size) {
        Page<UserView> result = followService.getFollowing(userId, pageable(page, size));
        return new UserListResponse(result.getContent(), toPageMeta(result));
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100));
    }

    private PageMetaResponse toPageMeta(Page<?> page) {
        return new PageMetaResponse(
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.hasNext()
        );
    }
}
