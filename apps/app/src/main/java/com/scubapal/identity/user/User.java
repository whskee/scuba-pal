package com.scubapal.identity.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

import com.scubapal.identity.role.Role;
import com.scubapal.shared.domain.SoftDeletableAuditableEntity;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "user_id"))
@Table(schema = "identity", name = "users")
public class User extends SoftDeletableAuditableEntity {

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "email_verified_at")
    private LocalDateTime emailVerifiedAt;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
}
