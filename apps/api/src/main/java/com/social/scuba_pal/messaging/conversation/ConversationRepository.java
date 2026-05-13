package com.social.scuba_pal.messaging.conversation;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ConversationRepository extends JpaRepository<Conversation, Long> {
    @Query("""
        SELECT c FROM Conversation c
        JOIN FETCH c.userOne
        JOIN FETCH c.userTwo
        WHERE c.userOne.id = :userId OR c.userTwo.id = :userId
        ORDER BY c.createdAt DESC
    """)
    List<Conversation> findAllForUser(Long userId);

    @EntityGraph(attributePaths = {"userOne", "userTwo"})
    @Query(value = """
        SELECT c FROM Conversation c
        WHERE c.userOne.id = :userId OR c.userTwo.id = :userId
        ORDER BY COALESCE(
            (SELECT MAX(m.createdAt) FROM DirectMessage m WHERE m.conversation.id = c.id),
            c.createdAt
        ) DESC
    """, countQuery = """
        SELECT COUNT(c) FROM Conversation c
        WHERE c.userOne.id = :userId OR c.userTwo.id = :userId
    """)
    Page<Conversation> findPageForUser(@Param("userId") Long userId, Pageable pageable);

    @Query("""
        SELECT c FROM Conversation c
        JOIN FETCH c.userOne
        JOIN FETCH c.userTwo
        WHERE (c.userOne.id = :firstUserId AND c.userTwo.id = :secondUserId)
           OR (c.userOne.id = :secondUserId AND c.userTwo.id = :firstUserId)
    """)
    Optional<Conversation> findBetweenUsers(Long firstUserId, Long secondUserId);
}
