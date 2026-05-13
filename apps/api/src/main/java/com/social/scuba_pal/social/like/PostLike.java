package com.social.scuba_pal.social.like;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.shared.domain.CreatedEntity;
import com.social.scuba_pal.social.post.Post;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "post_like_id"))
@Table(schema = "social", name = "post_likes")
public class PostLike extends CreatedEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
