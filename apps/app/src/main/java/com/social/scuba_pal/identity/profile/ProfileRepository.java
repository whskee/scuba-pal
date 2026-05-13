package com.social.scuba_pal.identity.profile;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface ProfileRepository extends JpaRepository<Profile, Long> {

    @EntityGraph(attributePaths = "user")
    Optional<Profile> findByUserId(Long userId);

    @Query("select p from Profile p join fetch p.user where p.user.id in :userIds")
    List<Profile> findAllByUserIdsWithUser(@Param("userIds") Collection<Long> userIds);
}