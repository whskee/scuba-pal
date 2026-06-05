package com.scubapal.notification;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.shared.exception.ResourceNotFoundException;

import java.util.List;

@Service
public class NotificationService {
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationService(NotificationRepository notificationRepository, UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<NotificationView> getNotifications(String username) {
        return getNotifications(username, Pageable.ofSize(20)).getContent();
    }

    @Transactional(readOnly = true)
    public Page<NotificationView> getNotifications(String username, Pageable pageable) {
        User user = currentUser(username);
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId(), pageable).map(this::toView);
    }

    @Transactional(readOnly = true)
    public long countUnread(String username) {
        User user = currentUser(username);
        return notificationRepository.countByUserIdAndReadFalse(user.getId());
    }

    @Transactional
    public void markAllRead(String username) {
        User user = currentUser(username);
        notificationRepository.markAllReadForUser(user.getId());
    }

    @Transactional
    public NotificationView markRead(String username, Long notificationId) {
        User user = currentUser(username);
        Notification notification = notificationRepository.findByIdAndUserId(notificationId, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
        if (!notification.isRead()) {
            notification.setRead(true);
        }
        return toView(notification);
    }

    @Transactional
    public void createForUser(User user, String title, String message) {
        Notification notification = new Notification();
        notification.setUser(user);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setRead(false);
        notificationRepository.save(notification);
    }

    private NotificationView toView(Notification n) {
        return new NotificationView(n.getId(), n.getTitle(), n.getMessage(), n.isRead(), n.getCreatedAt());
    }

    private User currentUser(String username) {
        return userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
