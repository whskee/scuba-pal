package com.scubapal.messaging;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.identity.role.Role;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.messaging.conversation.Conversation;
import com.scubapal.messaging.conversation.ConversationRepository;
import com.scubapal.messaging.message.Message;
import com.scubapal.messaging.message.MessageRepository;
import com.scubapal.notification.NotificationService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MessagingServiceTest {

    @Mock ConversationRepository conversationRepository;
    @Mock MessageRepository messageRepository;
    @Mock UserRepository userRepository;
    @Mock ProfileRepository profileRepository;
    @Mock NotificationService notificationService;
    @InjectMocks MessagingService messagingService;

    @Test
    void sendMessageTrimsTextSavesMessageAndNotifiesReceiver() {
        User dana = user(1L, "dana");
        User kai = user(2L, "kai");
        Conversation conversation = conversation(10L, dana, kai);
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(conversationRepository.findById(10L)).thenReturn(Optional.of(conversation));

        messagingService.sendMessage("dana", 10L, "  hey there  ");

        verify(messageRepository).save(argThat(message ->
                message.getConversation().equals(conversation)
                        && message.getSender().equals(dana)
                        && message.getMessageText().equals("hey there")
        ));
        verify(notificationService).createForUser(kai, "New message", "dana sent you a message.");
    }

    @Test
    void getMessagesMarksConversationReadAndMapsReadReceipts() {
        User dana = user(1L, "dana");
        User kai = user(2L, "kai");
        Conversation conversation = conversation(10L, dana, kai);
        Message unreadFromKai = message(100L, conversation, kai, "hello", null);
        Message readFromDana = message(101L, conversation, dana, "yo", LocalDateTime.now());
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(conversationRepository.findById(10L)).thenReturn(Optional.of(conversation));
        when(messageRepository.findByConversationIdOrderByCreatedAtAsc(eq(10L), any())).thenReturn(new PageImpl<>(List.of(unreadFromKai, readFromDana)));
        when(profileRepository.findAllByUserIdsWithUser(anyCollection())).thenReturn(List.of());

        var page = messagingService.getMessages("dana", 10L, PageRequest.of(0, 50));

        verify(messageRepository).markConversationMessagesRead(eq(10L), eq(1L), any(LocalDateTime.class));
        assertEquals(2, page.getTotalElements());
        assertFalse(page.getContent().get(0).sentByCurrentUser());
        assertTrue(page.getContent().get(1).sentByCurrentUser());
        assertNotNull(page.getContent().get(1).readAt());
    }

    @Test
    void countUnreadMessagesDelegatesToRepositoryForCurrentUser() {
        User dana = user(1L, "dana");
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(messageRepository.countUnreadForUser(1L)).thenReturn(7L);

        long unread = messagingService.countUnreadMessages("dana");

        assertEquals(7, unread);
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

    private static Conversation conversation(Long id, User one, User two) {
        Conversation conversation = new Conversation();
        conversation.setId(id);
        conversation.setUserOne(one);
        conversation.setUserTwo(two);
        return conversation;
    }

    private static Message message(Long id, Conversation conversation, User sender, String text, LocalDateTime readAt) {
        Message message = new Message();
        message.setId(id);
        message.setConversation(conversation);
        message.setSender(sender);
        message.setMessageText(text);
        message.setReadAt(readAt);
        return message;
    }
}
