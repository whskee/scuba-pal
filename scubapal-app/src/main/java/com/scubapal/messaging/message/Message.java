package com.scubapal.messaging.message;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

import com.scubapal.identity.user.User;
import com.scubapal.messaging.conversation.Conversation;
import com.scubapal.shared.domain.CreatedEntity;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "message_id"))
@Table(schema = "messaging", name = "messages")
public class Message extends CreatedEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    private Conversation conversation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_user_id", nullable = false)
    private User sender;

    @Column(name = "message_text", nullable = false, length = 1000)
    private String messageText;

    @Column(name = "read_at")
    private LocalDateTime readAt;
}
