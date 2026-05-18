package com.scubapal.identity.user;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    Optional<User> findByEmailIgnoreCase(String email);

    @EntityGraph(attributePaths = "role")
    Optional<User> findByUsername(String username);

    @Query("select u from User u join fetch u.role where u.username = :username")
    Optional<User> findByUsernameWithRole(@Param("username") String username);

    @Query("select u from User u join fetch u.role where u.id = :id")
    Optional<User> findByIdWithRole(@Param("id") Long id);

    @Query("select u from User u join fetch u.role order by u.username asc")
    List<User> findAllWithRoleOrderByUsernameAsc();

    @EntityGraph(attributePaths = "role")
    Page<User> findAllByOrderByUsernameAsc(Pageable pageable);
}
