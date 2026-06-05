package com.scubapal.identity.profile;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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

    @EntityGraph(attributePaths = {"user", "user.role"})
    Page<Profile> findByCityContainingIgnoreCase(String city, Pageable pageable);

    @Query(value = """
            select p from Profile p
            join fetch p.user u
            join fetch u.role
            where p.visibilityStatus = com.scubapal.shared.VisibilityStatus.PUBLIC
              and u.active = true
              and (
                    :term is null
                    or :term = ''
                    or lower(u.username) like lower(concat('%', :term, '%'))
                    or lower(p.firstName) like lower(concat('%', :term, '%'))
                    or lower(p.lastName) like lower(concat('%', :term, '%'))
                    or lower(p.city) like lower(concat('%', :term, '%'))
                    or lower(p.country) like lower(concat('%', :term, '%'))
                    or lower(p.bio) like lower(concat('%', :term, '%'))
              )
            order by u.username asc
            """,
            countQuery = """
            select count(p) from Profile p
            join p.user u
            where p.visibilityStatus = com.scubapal.shared.VisibilityStatus.PUBLIC
              and u.active = true
              and (
                    :term is null
                    or :term = ''
                    or lower(u.username) like lower(concat('%', :term, '%'))
                    or lower(p.firstName) like lower(concat('%', :term, '%'))
                    or lower(p.lastName) like lower(concat('%', :term, '%'))
                    or lower(p.city) like lower(concat('%', :term, '%'))
                    or lower(p.country) like lower(concat('%', :term, '%'))
                    or lower(p.bio) like lower(concat('%', :term, '%'))
              )
            """)
    Page<Profile> searchPublicProfiles(@Param("term") String term, Pageable pageable);

    @Query("select p from Profile p join fetch p.user where p.user.id in :userIds")
    List<Profile> findAllByUserIdsWithUser(@Param("userIds") Collection<Long> userIds);
}
