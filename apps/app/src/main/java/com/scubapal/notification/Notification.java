package com.scubapal.notification;

import com.scubapal.identity.user.User;
import com.scubapal.shared.domain.CreatedEntity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "notification_id"))
@Table(schema = "notification", name = "notifications")
public class Notification extends CreatedEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String message;

    @Column(name = "is_read", nullable = false)
    private boolean read;
}
