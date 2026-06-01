package com.scubapal.identity.user;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmailIgnoreCase(String email);

    @EntityGraph(attributePaths = "role")
    Optional<User> findByUsernameIgnoreCase(String username);

    @Query("select u from User u join fetch u.role where u.id = :id")
    Optional<User> findByIdWithRole(@Param("id") Long id);

    @EntityGraph(attributePaths = "role")
    Page<User> findAllByOrderByUsernameAsc(Pageable pageable);
}
