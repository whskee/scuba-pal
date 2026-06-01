package com.scubapal.identity.auth;

import java.time.Instant;

import com.scubapal.identity.user.User;
import com.scubapal.shared.domain.CreatedEntity;

import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "refresh_token_id"))
@Table(schema = "identity", name = "refresh_tokens")
public class RefreshToken extends CreatedEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "token_hash", nullable = false, unique = true, length = 64)
    private String tokenHash;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "revoked_at")
    private Instant revokedAt;

    @Column(name = "replaced_by_token_hash", length = 64)
    private String replacedByTokenHash;

    @Column(name = "created_by_ip", length = 64)
    private String createdByIp;

    @Column(name = "revoked_by_ip", length = 64)
    private String revokedByIp;

    public boolean isUsable(Instant now) {
        return revokedAt == null && expiresAt.isAfter(now);
    }
}
