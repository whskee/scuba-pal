package com.scubapal.messaging;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class MessagingPageController {
    private final MessagingService messagingService;

    public MessagingPageController(MessagingService messagingService) {
        this.messagingService = messagingService;
    }

    @PostMapping("/messages/start/{userId}")
    public String startMessage(@PathVariable Long userId, Authentication auth) {
        return "redirect:/messages/" + messagingService.startConversation(auth.getName(), userId);
    }

    @GetMapping("/messages")
    public String messages(@RequestParam(defaultValue = "0") int page,
                           @RequestParam(defaultValue = "20") int size,
                           Model model,
                           Authentication auth) {
        var conversationPage = messagingService.getConversations(auth.getName(), pageable(page, size));
        model.addAttribute("conversationPage", conversationPage);
        model.addAttribute("conversations", conversationPage.getContent());
        return "messaging/messages";
    }

    @GetMapping("/messages/{conversationId}")
    public String conversation(@PathVariable Long conversationId,
                               @RequestParam(defaultValue = "0") int page,
                               @RequestParam(defaultValue = "50") int size,
                               Model model,
                               Authentication auth) {
        var messagePage = messagingService.getMessages(auth.getName(), conversationId, pageable(page, size));
        model.addAttribute("conversation", messagingService.getConversation(auth.getName(), conversationId));
        model.addAttribute("messagePage", messagePage);
        model.addAttribute("messages", messagePage.getContent());
        model.addAttribute("unreadMessageCount", messagingService.countUnreadMessages(auth.getName()));
        return "messaging/conversation";
    }

    @PostMapping("/messages/{conversationId}")
    public String sendMessage(@PathVariable Long conversationId,
                              @RequestParam String messageText,
                              Authentication auth) {
        messagingService.sendMessage(auth.getName(), conversationId, messageText);
        return "redirect:/messages/" + conversationId;
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100));
    }
}
