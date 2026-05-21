package com.scubapal.messaging.message;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface MessageRepository extends JpaRepository<Message, Long> {
    @Query("""
        SELECT m FROM Message m
        JOIN FETCH m.sender
        WHERE m.conversation.id = :conversationId
        ORDER BY m.createdAt ASC
    """)
    List<Message> findByConversationIdOrderByCreatedAtAsc(Long conversationId);

    @EntityGraph(attributePaths = "sender")
    Page<Message> findByConversationIdOrderByCreatedAtAsc(Long conversationId, Pageable pageable);

    @Query("""
        SELECT COUNT(m) FROM Message m
        WHERE m.conversation.id = :conversationId
          AND m.sender.id <> :userId
          AND m.readAt IS NULL
    """)
    long countUnreadInConversation(@Param("conversationId") Long conversationId, @Param("userId") Long userId);

    @Query("""
        SELECT COUNT(m) FROM Message m
        WHERE (m.conversation.userOne.id = :userId OR m.conversation.userTwo.id = :userId)
          AND m.sender.id <> :userId
          AND m.readAt IS NULL
    """)
    long countUnreadForUser(@Param("userId") Long userId);

    @Modifying
    @Query("""
        UPDATE Message m
        SET m.readAt = :readAt
        WHERE m.conversation.id = :conversationId
          AND m.sender.id <> :readerId
          AND m.readAt IS NULL
    """)
    int markConversationMessagesRead(@Param("conversationId") Long conversationId, @Param("readerId") Long readerId, @Param("readAt") LocalDateTime readAt);

    Optional<Message> findTopByConversationIdOrderByCreatedAtDesc(Long conversationId);
}
