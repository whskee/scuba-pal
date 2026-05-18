package com.scubapal.social.post;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

import com.scubapal.identity.user.User;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.shared.domain.SoftDeletableAuditableEntity;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "post_id"))
@Table(schema = "social", name = "posts")
public class Post extends SoftDeletableAuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String caption;

    @Enumerated(EnumType.STRING)
    @Column(name = "post_type", nullable = false)
    private PostType postType = PostType.TEXT;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility_status", nullable = false)
    private VisibilityStatus visibilityStatus = VisibilityStatus.PUBLIC;

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("displayOrder ASC, id ASC")
    private List<PostMedia> media = new ArrayList<>();
}
