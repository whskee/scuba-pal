package com.social.scuba_pal.messaging;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.identity.user.UserRepository;
import com.social.scuba_pal.messaging.conversation.Conversation;
import com.social.scuba_pal.messaging.conversation.ConversationRepository;
import com.social.scuba_pal.messaging.message.DirectMessageRepository;
import com.social.scuba_pal.notification.NotificationService;
import com.social.scuba_pal.shared.exception.ResourceNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MessagingServiceAccessTest {
    @Mock ConversationRepository conversationRepository;
    @Mock DirectMessageRepository directMessageRepository;
    @Mock UserRepository userRepository;
    @Mock NotificationService notificationService;
    @InjectMocks MessagingService messagingService;

    @Test
    void getConversationRejectsNonParticipant() {
        User alice = user(1L, "alice");
        User bob = user(2L, "bob");
        User intruder = user(3L, "intruder");
        Conversation conversation = new Conversation();
        conversation.setId(99L);
        conversation.setUserOne(alice);
        conversation.setUserTwo(bob);

        when(userRepository.findByUsername("intruder")).thenReturn(Optional.of(intruder));
        when(conversationRepository.findById(99L)).thenReturn(Optional.of(conversation));

        assertThrows(ResourceNotFoundException.class, () -> messagingService.getConversation("intruder", 99L));
    }

    private User user(Long id, String username) {
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setEmail(username + "@example.com");
        return user;
    }
}
