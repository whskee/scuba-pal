package com.scubapal.social.comment;

import com.scubapal.identity.user.User;
import com.scubapal.shared.domain.SoftDeletableAuditableEntity;
import com.scubapal.social.post.Post;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "post_comment_id"))
@Table(schema = "social", name = "post_comments")
public class PostComment extends SoftDeletableAuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "comment_text", nullable = false)
    private String commentText;
}
