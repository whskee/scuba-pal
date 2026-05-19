package com.scubapal.social.like;

import com.scubapal.identity.user.User;
import com.scubapal.shared.domain.CreatedEntity;
import com.scubapal.social.post.Post;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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
