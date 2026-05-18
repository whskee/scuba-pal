package com.scubapal.social.follow;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserFollowRepository extends JpaRepository<UserFollow, Long> {
    Optional<UserFollow> findByFollowerIdAndFollowedId(Long followerId, Long followedId);

    boolean existsByFollowerIdAndFollowedId(Long followerId, Long followedId);

    long countByFollowerId(Long followerId);

    long countByFollowedId(Long followedId);

    @Query("select uf from UserFollow uf join fetch uf.followed followed join fetch followed.role where uf.follower.id = :userId order by followed.username asc")
    List<UserFollow> findFollowing(@Param("userId") Long userId);

    @Query("select uf from UserFollow uf join fetch uf.follower follower join fetch follower.role where uf.followed.id = :userId order by follower.username asc")
    List<UserFollow> findFollowers(@Param("userId") Long userId);

    @Query(value = "select uf from UserFollow uf join fetch uf.followed followed join fetch followed.role where uf.follower.id = :userId order by followed.username asc",
           countQuery = "select count(uf) from UserFollow uf where uf.follower.id = :userId")
    Page<UserFollow> findFollowing(@Param("userId") Long userId, Pageable pageable);

    @Query(value = "select uf from UserFollow uf join fetch uf.follower follower join fetch follower.role where uf.followed.id = :userId order by follower.username asc",
           countQuery = "select count(uf) from UserFollow uf where uf.followed.id = :userId")
    Page<UserFollow> findFollowers(@Param("userId") Long userId, Pageable pageable);
}
