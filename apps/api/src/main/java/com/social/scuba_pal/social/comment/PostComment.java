package com.social.scuba_pal.social.comment;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.shared.domain.SoftDeletableAuditableEntity;
import com.social.scuba_pal.social.post.Post;

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
