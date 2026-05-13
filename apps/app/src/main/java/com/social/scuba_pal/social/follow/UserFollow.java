package com.social.scuba_pal.social.follow;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.shared.domain.CreatedEntity;

import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "user_follow_id"))
@Table(schema = "social", name = "user_follows", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"follower_user_id", "followed_user_id"})
})
public class UserFollow extends CreatedEntity {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "follower_user_id", nullable = false)
    private User follower;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "followed_user_id", nullable = false)
    private User followed;
}
