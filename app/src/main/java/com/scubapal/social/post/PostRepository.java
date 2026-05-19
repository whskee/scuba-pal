package com.scubapal.social.post;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.scubapal.shared.VisibilityStatus;

import java.util.Optional;

public interface PostRepository extends JpaRepository<Post, Long> {

    @EntityGraph(attributePaths = "user")
    Page<Post> findByVisibilityStatusOrderByCreatedAtDesc(VisibilityStatus visibilityStatus, Pageable pageable);

    @EntityGraph(attributePaths = "user")
    Page<Post> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    @Query("""
        SELECT DISTINCT p
        FROM Post p
        JOIN FETCH p.user
        LEFT JOIN FETCH p.media
        WHERE p.id = :postId
    """)
    Optional<Post> findByIdWithUser(Long postId);
}
