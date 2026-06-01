package com.scubapal.messaging;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.messaging.conversation.Conversation;
import com.scubapal.messaging.conversation.ConversationRepository;
import com.scubapal.messaging.conversation.ConversationView;
import com.scubapal.messaging.message.Message;
import com.scubapal.messaging.message.MessageRepository;
import com.scubapal.messaging.message.MessageView;
import com.scubapal.notification.NotificationService;
import com.scubapal.shared.exception.ResourceNotFoundException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class MessagingService {
        private final ConversationRepository conversationRepository;
        private final MessageRepository messageRepository;
        private final UserRepository userRepository;
        private final ProfileRepository profileRepository;
        private final NotificationService notificationService;

        public MessagingService(ConversationRepository conversationRepository,
                                MessageRepository messageRepository,
                                UserRepository userRepository,
                                ProfileRepository profileRepository,
                                NotificationService notificationService) {
                this.conversationRepository = conversationRepository;
                this.messageRepository = messageRepository;
                this.userRepository = userRepository;
                this.profileRepository = profileRepository;
                this.notificationService = notificationService;
        }

        @Transactional(readOnly = true)
        public List<ConversationView> getConversations(String username) {
                return getConversations(username, Pageable.ofSize(20)).getContent();
        }

        @Transactional(readOnly = true)
        public Page<ConversationView> getConversations(String username, Pageable pageable) {
                User me = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Page<Conversation> conversations = conversationRepository.findPageForUser(me.getId(), pageable);
                Map<Long, Profile> profilesByUserId = loadProfilesForUsers(conversations.getContent().stream()
                                .map(c -> otherParticipant(c, me.getId()).getId())
                                .toList());
                return conversations.map(c -> toConversationView(c, me.getId(), profilesByUserId));
        }

        @Transactional(readOnly = true)
        public long countUnreadMessages(String username) {
                User me = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                return messageRepository.countUnreadForUser(me.getId());
        }

        @Transactional
        public Long startConversation(String username, Long otherUserId) {
                User me = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                if (me.getId().equals(otherUserId))
                        throw new IllegalArgumentException("You cannot message yourself.");
                User other = userRepository.findById(otherUserId)
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Long low = Math.min(me.getId(), other.getId());
                Long high = Math.max(me.getId(), other.getId());
                return conversationRepository.findBetweenUsers(low, high).orElseGet(() -> {
                        Conversation c = new Conversation();
                        c.setUserOne(me.getId().equals(low) ? me : other);
                        c.setUserTwo(me.getId().equals(high) ? me : other);
                        try {
                                return conversationRepository.save(c);
                        } catch (DataIntegrityViolationException ex) {
                                return conversationRepository.findBetweenUsers(low, high)
                                                .orElseThrow(() -> ex);
                        }
                }).getId();
        }

        @Transactional(readOnly = true)
        public ConversationView getConversation(String username, Long conversationId) {
                User me = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation c = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(c, me.getId());
                Map<Long, Profile> profilesByUserId = loadProfilesForUsers(List.of(otherParticipant(c, me.getId()).getId()));
                return toConversationView(c, me.getId(), profilesByUserId);
        }

        @Transactional
        public List<MessageView> getMessages(String username, Long conversationId) {
                return getMessages(username, conversationId, Pageable.ofSize(50)).getContent();
        }

        @Transactional
        public Page<MessageView> getMessages(String username, Long conversationId, Pageable pageable) {
                markConversationRead(username, conversationId);
                User me = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation conversation = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(conversation, me.getId());
                Page<Message> messages = messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId, pageable);
                Map<Long, Profile> profilesByUserId = loadProfilesForUsers(messages.getContent().stream()
                                .map(m -> m.getSender().getId())
                                .distinct()
                                .toList());
                return messages.map(m -> new MessageView(m.getId(), m.getSender().getId(),
                                                m.getSender().getUsername(),
                                                profileImageUrl(profilesByUserId.get(m.getSender().getId())),
                                                m.getMessageText(), m.getCreatedAt(), m.getReadAt(),
                                                m.getSender().getId().equals(me.getId())));
        }

        @Transactional
        public void markConversationRead(String username, Long conversationId) {
                User me = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation conversation = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(conversation, me.getId());
                messageRepository.markConversationMessagesRead(conversationId, me.getId(), LocalDateTime.now());
        }

        @Transactional
        public void sendMessage(String username, Long conversationId, String messageText) {
                if (messageText == null || messageText.trim().isBlank())
                        throw new IllegalArgumentException("Message cannot be blank.");
                String normalizedMessage = messageText.trim();
                if (normalizedMessage.length() > 1000) {
                        throw new IllegalArgumentException("Message must be 1000 characters or fewer.");
                }
                User me = userRepository.findByUsernameIgnoreCase(username == null ? "" : username.trim())
                                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                Conversation conversation = conversationRepository.findById(conversationId)
                                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
                ensureParticipant(conversation, me.getId());
                Message message = new Message();
                message.setConversation(conversation);
                message.setSender(me);
                message.setMessageText(normalizedMessage);
                messageRepository.save(message);
                User receiver = conversation.getUserOne().getId().equals(me.getId())
                                ? conversation.getUserTwo()
                                : conversation.getUserOne();
                notificationService.createForUser(receiver, "New message", me.getUsername() + " sent you a message.");
        }

        private void ensureParticipant(Conversation c, Long userId) {
                if (!c.getUserOne().getId().equals(userId) && !c.getUserTwo().getId().equals(userId)) {
                        throw new ResourceNotFoundException("Conversation not found");
                }
        }

        private User otherParticipant(Conversation c, Long meId) {
                return c.getUserOne().getId().equals(meId) ? c.getUserTwo() : c.getUserOne();
        }

        private ConversationView toConversationView(Conversation c, Long meId, Map<Long, Profile> profilesByUserId) {
                User other = otherParticipant(c, meId);
                String initial = other.getUsername().substring(0, 1).toUpperCase();
                long unread = messageRepository.countUnreadInConversation(c.getId(), meId);
                var latestMessage = messageRepository.findTopByConversationIdOrderByCreatedAtDesc(c.getId());
                String preview = latestMessage
                                .map(Message::getMessageText)
                                .map(text -> text.length() > 90 ? text.substring(0, 90) + "..." : text)
                                .orElse("No messages yet");
                LocalDateTime updatedAt = latestMessage.map(Message::getCreatedAt).orElse(c.getCreatedAt());
                return new ConversationView(c.getId(), other.getId(), other.getUsername(), initial,
                                profileImageUrl(profilesByUserId.get(other.getId())), unread, preview, updatedAt);
        }

        private Map<Long, Profile> loadProfilesForUsers(List<Long> userIds) {
                List<Long> distinctIds = userIds.stream().distinct().toList();
                if (distinctIds.isEmpty()) {
                        return Map.of();
                }
                return profileRepository.findAllByUserIdsWithUser(distinctIds).stream()
                                .collect(Collectors.toMap(profile -> profile.getUser().getId(), Function.identity()));
        }

        private String profileImageUrl(Profile profile) {
                return profile != null ? profile.getProfileImageUrl() : null;
        }
}
