package com.scubapal.notification;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.scubapal.shared.api.PageMetaResponse;

@Tag(name = "Notifications", description = "Endpoints for listing and acknowledging notifications")
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    @Operation(summary = "List notifications", description = "Returns paged notifications for the authenticated user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Notification list returned"),
            @ApiResponse(responseCode = "401", description = "Authentication required")
    })
    public NotificationListResponse notifications(@RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "20") int size,
                                                  Authentication authentication) {
        Pageable pageable = PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100));
        Page<NotificationView> result = notificationService.getNotifications(authentication.getName(), pageable);
        return new NotificationListResponse(result.getContent(), toPageMeta(result));
    }

    @RequestMapping(value = "/{notificationId}/read", method = {RequestMethod.PATCH, RequestMethod.POST})
    @Operation(summary = "Mark notification as read", description = "Marks one notification as read for the authenticated user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Notification marked read"),
            @ApiResponse(responseCode = "401", description = "Authentication required"),
            @ApiResponse(responseCode = "404", description = "Notification not found")
    })
    public NotificationView markRead(@PathVariable Long notificationId, Authentication authentication) {
        return notificationService.markRead(authentication.getName(), notificationId);
    }

    @GetMapping("/unread-count")
    @Operation(summary = "Get unread notification count", description = "Returns unread notification count for the authenticated user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Unread count returned"),
            @ApiResponse(responseCode = "401", description = "Authentication required")
    })
    public UnreadNotificationCountView unreadCount(Authentication authentication) {
        return new UnreadNotificationCountView(notificationService.countUnread(authentication.getName()));
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
