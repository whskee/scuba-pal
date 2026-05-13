package com.social.scuba_pal.notification;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class NotificationPageController {
    private final NotificationService notificationService;

    public NotificationPageController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping("/notifications")
    public String notifications(@RequestParam(defaultValue = "0") int page,
                                @RequestParam(defaultValue = "20") int size,
                                Model model,
                                Authentication auth) {
        var notificationPage = notificationService.getNotifications(auth.getName(), pageable(page, size));
        model.addAttribute("notificationPage", notificationPage);
        model.addAttribute("notifications", notificationPage.getContent());
        notificationService.markAllRead(auth.getName());
        return "notification/notifications";
    }

    private Pageable pageable(int page, int size) {
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50));
    }
}
