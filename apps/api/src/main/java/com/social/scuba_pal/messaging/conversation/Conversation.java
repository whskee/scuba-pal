package com.social.scuba_pal.messaging.conversation;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.shared.domain.CreatedEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "conversation_id"))
@Table(schema = "messaging", name = "conversations", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_one_id", "user_two_id"})
})
public class Conversation extends CreatedEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_one_id", nullable = false)
    private User userOne;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_two_id", nullable = false)
    private User userTwo;
}
