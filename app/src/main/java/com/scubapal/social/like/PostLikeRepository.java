package com.scubapal.social.like;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface PostLikeRepository extends JpaRepository<PostLike, Long> {

    @Query("select count(pl) from PostLike pl where pl.post.id = :postId")
    long countByPostId(@Param("postId") Long postId);

    Optional<PostLike> findByPostIdAndUserId(Long postId, Long userId);

    boolean existsByPostIdAndUserId(Long postId, Long userId);

    @Query("""
        select pl.post.id
        from PostLike pl
        where pl.user.id = :userId
        and pl.post.id in :postIds
    """)
    List<Long> findLikedPostIds(@Param("userId") Long userId, @Param("postIds") Collection<Long> postIds);
}
