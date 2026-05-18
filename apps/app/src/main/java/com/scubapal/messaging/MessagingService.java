package com.scubapal.messaging;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.messaging.conversation.Conversation;
import com.scubapal.messaging.conversation.ConversationRepository;
import com.scubapal.messaging.conversation.ConversationView;
import com.scubapal.messaging.message.DirectMessage;
import com.scubapal.messaging.message.DirectMessageRepository;
import com.scubapal.messaging.message.DirectMessageView;
import com.scubapal.notification.NotificationService;
import com.scubapal.shared.exception.ResourceNotFoundException;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MessagingService {
        private final ConversationRepository conversationRepository;
        private final DirectMessageRepository directMessageRepository;
        private final UserRepository userRepository;
        private final NotificationService notificationService;

        public MessagingService(ConversationRepository conversationRepository,
                        DirectMessageRepository directMessageRepository,
                        UserRepository userRepository,
                        NotificationService notificationService) {
                this.conversationRepository = conversationRepository;
                this.directMessageRepository = directMessageRepository;
                this.userRepository = userRepository;
                this.notificationService = notificationService;
        }

        @Transactional(readOnly = true)
        public List<ConversationView> getConversations(String username) {
                return getConversations(username, Pageable.ofSize(20)).getContent();
        }

        @Transactional(readOnly = true)
        public Page<ConversationView> getConversations(String username, Pageable pageable) {
                User me = userRepository.findByUsername(username)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                return conversationRepository.findPageForUser(me.getId(), pageable)
                                .map(c -> toConversationView(c, me.getId()));
        }

        @Transactional(readOnly = true)
        public long countUnreadMessages(String username) {
                User me = userRepository.findByUsername(username)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                return directMessageRepository.countUnreadForUser(me.getId());
        }

        @Transactional
        public Long startConversation(String username, Long otherUserId) {
                User me = userRepository.findByUsername(username)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                if (me.getId().equals(otherUserId))
                        throw new IllegalArgumentException("You cannot message yourself.");
                User other = userRepository.findById(otherUserId)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Long low = Math.min(me.getId(), other.getId());
                Long high = Math.max(me.getId(), other.getId());
                return conversationRepository.findBetweenUsers(low, high).orElseGet(() -> {
                        Conversation c = new Conversation();
                        c.setUserOne(userRepository.findById(low).orElseThrow());
                        c.setUserTwo(userRepository.findById(high).orElseThrow());
                        return conversationRepository.save(c);
                }).getId();
        }

        @Transactional(readOnly = true)
        public ConversationView getConversation(String username, Long conversationId) {
                User me = userRepository.findByUsername(username)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation c = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(c, me.getId());
                return toConversationView(c, me.getId());
        }

        @Transactional
        public List<DirectMessageView> getMessages(String username, Long conversationId) {
                return getMessages(username, conversationId, Pageable.ofSize(50)).getContent();
        }

        @Transactional
        public Page<DirectMessageView> getMessages(String username, Long conversationId, Pageable pageable) {
                markConversationRead(username, conversationId);
                User me = userRepository.findByUsername(username)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation conversation = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(conversation, me.getId());
                return directMessageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId, pageable)
                                .map(m -> new DirectMessageView(m.getId(), m.getSender().getId(),
                                                m.getSender().getUsername(),
                                                m.getMessageText(), m.getCreatedAt(), m.getReadAt(),
                                                m.getSender().getId().equals(me.getId())));
        }

        @Transactional
        public void markConversationRead(String username, Long conversationId) {
                User me = userRepository.findByUsername(username)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation conversation = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(conversation, me.getId());
                directMessageRepository.markConversationMessagesRead(conversationId, me.getId(), LocalDateTime.now());
        }

        @Transactional
        public void sendMessage(String username, Long conversationId, String messageText) {
                if (messageText == null || messageText.trim().isBlank())
                        throw new IllegalArgumentException("Message cannot be blank.");
                User me = userRepository.findByUsername(username)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation conversation = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(conversation, me.getId());
                DirectMessage message = new DirectMessage();
                message.setConversation(conversation);
                message.setSender(me);
                message.setMessageText(messageText.trim());
                directMessageRepository.save(message);
                User receiver = conversation.getUserOne().getId().equals(me.getId()) ? conversation.getUserTwo()
                                : conversation.getUserOne();
                notificationService.createForUser(receiver, "New message", me.getUsername() + " sent you a message.");
        }

        private void ensureParticipant(Conversation c, Long userId) {
                if (!c.getUserOne().getId().equals(userId) && !c.getUserTwo().getId().equals(userId)) {
                        throw new ResourceNotFoundException("Conversation not found");
                }
        }

        private ConversationView toConversationView(Conversation c, Long meId) {
                User other = c.getUserOne().getId().equals(meId) ? c.getUserTwo() : c.getUserOne();
                String initial = other.getUsername().substring(0, 1).toUpperCase();
                long unread = directMessageRepository.countUnreadInConversation(c.getId(), meId);
                var latestMessage = directMessageRepository.findTopByConversationIdOrderByCreatedAtDesc(c.getId());
                String preview = latestMessage
                                .map(DirectMessage::getMessageText)
                                .map(text -> text.length() > 90 ? text.substring(0, 90) + "..." : text)
                                .orElse("No messages yet");
                LocalDateTime updatedAt = latestMessage.map(DirectMessage::getCreatedAt).orElse(c.getCreatedAt());
                return new ConversationView(c.getId(), other.getId(), other.getUsername(), initial, unread, preview,
                                updatedAt);
        }
}
