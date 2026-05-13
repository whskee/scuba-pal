package com.social.scuba_pal.social.comment;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PostCommentRepository extends JpaRepository<PostComment, Long> {

    @Query("select count(pc) from PostComment pc where pc.post.id = :postId")
    long countByPostId(@Param("postId") Long postId);

    @Query("""
        select pc
        from PostComment pc
        join fetch pc.user
        where pc.post.id = :postId
        order by pc.createdAt asc
    """)
    List<PostComment> findByPostIdWithUserOrderByCreatedAtAsc(@Param("postId") Long postId);

    @Query("""
        select pc
        from PostComment pc
        join fetch pc.user
        join fetch pc.post p
        join fetch p.user
        where pc.id = :commentId
    """)
    Optional<PostComment> findByIdWithPostAndUser(@Param("commentId") Long commentId);
}
