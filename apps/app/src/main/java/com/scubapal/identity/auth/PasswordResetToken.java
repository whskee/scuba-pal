package com.scubapal.identity.auth;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

import com.scubapal.identity.user.User;
import com.scubapal.shared.domain.CreatedEntity;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "password_reset_token_id"))
@Table(schema = "identity", name = "password_reset_tokens")
public class PasswordResetToken extends CreatedEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "token", nullable = false, unique = true, length = 120)
    private String token;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "used_at")
    private LocalDateTime usedAt;

    public boolean isUsable() {
        return usedAt == null && expiresAt.isAfter(LocalDateTime.now());
    }
}
