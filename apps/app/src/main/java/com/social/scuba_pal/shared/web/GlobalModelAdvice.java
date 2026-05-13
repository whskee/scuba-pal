package com.social.scuba_pal.shared.web;

import com.social.scuba_pal.identity.user.UserService;
import com.social.scuba_pal.identity.user.UserView;
import com.social.scuba_pal.messaging.MessagingService;
import com.social.scuba_pal.notification.NotificationService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalModelAdvice {
    private final MessagingService messagingService;
    private final NotificationService notificationService;
    private final UserService userService;

    public GlobalModelAdvice(MessagingService messagingService, NotificationService notificationService, UserService userService) {
        this.messagingService = messagingService;
        this.notificationService = notificationService;
        this.userService = userService;
    }

    @ModelAttribute("currentUser")
    public UserView currentUser(Authentication auth) {
        if (!isLoggedIn(auth)) return null;
        return userService.getCurrentUser(auth.getName());
    }

    @ModelAttribute("unreadMessageCount")
    public long unreadMessageCount(Authentication auth) {
        if (!isLoggedIn(auth)) return 0;
        return messagingService.countUnreadMessages(auth.getName());
    }

    @ModelAttribute("unreadNotificationCount")
    public long unreadNotificationCount(Authentication auth) {
        if (!isLoggedIn(auth)) return 0;
        return notificationService.countUnread(auth.getName());
    }

    @ModelAttribute("requestPath")
    public String requestPath(HttpServletRequest request) {
        return request.getRequestURI();
    }

    private boolean isLoggedIn(Authentication auth) {
        return auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName());
    }
}
