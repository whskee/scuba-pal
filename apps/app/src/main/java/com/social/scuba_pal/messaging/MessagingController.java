package com.social.scuba_pal.messaging;

import com.social.scuba_pal.messaging.conversation.ConversationListResponse;
import com.social.scuba_pal.messaging.conversation.ConversationView;
import com.social.scuba_pal.messaging.message.DirectMessageListResponse;
import com.social.scuba_pal.messaging.message.DirectMessageView;
import com.social.scuba_pal.messaging.message.MessageResponse;
import com.social.scuba_pal.messaging.message.SendMessageRequest;
import com.social.scuba_pal.messaging.message.UnreadCountView;
import com.social.scuba_pal.notification.NotificationService;
import com.social.scuba_pal.shared.api.PageMetaResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Messaging", description = "Endpoints for conversations and direct messaging")
@RestController
@RequestMapping("/api/messages")
public class MessagingController {
    private final MessagingService messagingService;
    private final NotificationService notificationService;

    public MessagingController(MessagingService messagingService, NotificationService notificationService) {
        this.messagingService = messagingService;
        this.notificationService = notificationService;
    }

    @GetMapping("/conversations")
    @Operation(summary = "List conversations", description = "Returns paged conversations for the authenticated user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Conversation list returned"),
            @ApiResponse(responseCode = "401", description = "Authentication required")
    })
    public ConversationListResponse conversations(@RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "20") int size,
                                                  Authentication authentication) {
        Pageable pageable = PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100));
        Page<ConversationView> result = messagingService.getConversations(authentication.getName(), pageable);
        return new ConversationListResponse(result.getContent(), toPageMeta(result));
    }


    @PostMapping("/conversations/{otherUserId}")
    @Operation(summary = "Start conversation", description = "Finds or creates a direct-message conversation with another user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Conversation returned"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Authentication required"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ConversationView startConversation(@PathVariable Long otherUserId, Authentication authentication) {
        Long conversationId = messagingService.startConversation(authentication.getName(), otherUserId);
        return messagingService.getConversation(authentication.getName(), conversationId);
    }

    @PostMapping("/{conversationId}/read")
    @Operation(summary = "Mark conversation messages as read", description = "Marks all unread messages in a conversation as read for the authenticated user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Unread counters returned"),
            @ApiResponse(responseCode = "401", description = "Authentication required"),
            @ApiResponse(responseCode = "404", description = "Conversation not found")
    })
    public UnreadCountView markRead(@PathVariable Long conversationId, Authentication authentication) {
        messagingService.markConversationRead(authentication.getName(), conversationId);
        return new UnreadCountView(messagingService.countUnreadMessages(authentication.getName()), notificationService.countUnread(authentication.getName()));
    }

    @GetMapping("/{conversationId}")
    @Operation(summary = "List direct messages", description = "Returns paged direct messages for a conversation and marks unread items as read.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Message list returned"),
            @ApiResponse(responseCode = "401", description = "Authentication required"),
            @ApiResponse(responseCode = "404", description = "Conversation not found")
    })
    public DirectMessageListResponse messages(@PathVariable Long conversationId,
                                              @RequestParam(defaultValue = "0") int page,
                                              @RequestParam(defaultValue = "50") int size,
                                              Authentication authentication) {
        Pageable pageable = PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100));
        Page<DirectMessageView> result = messagingService.getMessages(authentication.getName(), conversationId, pageable);
        return new DirectMessageListResponse(result.getContent(), toPageMeta(result));
    }

    @PostMapping("/{conversationId}")
    @Operation(summary = "Send direct message", description = "Sends a message to a conversation participant.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Message sent"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Authentication required"),
            @ApiResponse(responseCode = "404", description = "Conversation not found")
    })
    public ResponseEntity<MessageResponse> sendMessage(@PathVariable Long conversationId,
                                                       @Valid @RequestBody SendMessageRequest request,
                                                       Authentication authentication) {
        messagingService.sendMessage(authentication.getName(), conversationId, request.messageText());
        return ResponseEntity.status(HttpStatus.CREATED).body(new MessageResponse("Message sent"));
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
