package com.social.scuba_pal.messaging.message;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.messaging.conversation.Conversation;
import com.social.scuba_pal.shared.domain.CreatedEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "direct_message_id"))
@Table(schema = "messaging", name = "direct_messages")
public class DirectMessage extends CreatedEntity {

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
