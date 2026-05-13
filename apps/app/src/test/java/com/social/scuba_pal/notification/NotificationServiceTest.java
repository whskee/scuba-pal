package com.social.scuba_pal.notification;

import com.social.scuba_pal.identity.role.Role;
import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.identity.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock NotificationRepository notificationRepository;
    @Mock UserRepository userRepository;
    @InjectMocks NotificationService notificationService;

    @Test
    void getNotificationsReturnsPagedNotificationsForCurrentUser() {
        User dana = user(1L, "dana");
        Notification notification = notification(5L, dana, "New follower", "kai started following you.", false);
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(1L, PageRequest.of(0, 20)))
                .thenReturn(new PageImpl<>(List.of(notification)));

        var page = notificationService.getNotifications("dana", PageRequest.of(0, 20));

        assertEquals(1, page.getTotalElements());
        assertEquals("New follower", page.getContent().get(0).title());
        assertFalse(page.getContent().get(0).read());
    }

    @Test
    void countUnreadUsesCurrentUserId() {
        User dana = user(1L, "dana");
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(notificationRepository.countByUserIdAndReadFalse(1L)).thenReturn(4L);

        assertEquals(4, notificationService.countUnread("dana"));
    }

    @Test
    void markAllReadUpdatesOnlyCurrentUsersNotifications() {
        User dana = user(1L, "dana");
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));

        notificationService.markAllRead("dana");

        verify(notificationRepository).markAllReadForUser(1L);
    }

    @Test
    void createForUserSavesUnreadNotification() {
        User dana = user(1L, "dana");

        notificationService.createForUser(dana, "New message", "kai sent you a message.");

        verify(notificationRepository).save(argThat(notification ->
                notification.getUser().equals(dana)
                        && notification.getTitle().equals("New message")
                        && notification.getMessage().equals("kai sent you a message.")
                        && !notification.isRead()
        ));
    }

    @Test
    void markReadMarksMatchingNotificationAsRead() {
        User dana = user(1L, "dana");
        Notification notification = notification(9L, dana, "New message", "kai sent you a message.", false);
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(notificationRepository.findByIdAndUserId(9L, 1L)).thenReturn(Optional.of(notification));

        NotificationView updated = notificationService.markRead("dana", 9L);

        assertTrue(updated.read());
        assertEquals(9L, updated.notificationId());
    }

    private static User user(Long id, String username) {
        Role role = new Role();
        role.setId(1L);
        role.setName("user");
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setEmail(username + "@example.com");
        user.setPasswordHash("hash");
        user.setRole(role);
        user.setActive(true);
        return user;
    }

    private static Notification notification(Long id, User user, String title, String message, boolean read) {
        Notification notification = new Notification();
        notification.setId(id);
        notification.setUser(user);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setRead(read);
        return notification;
    }
}
