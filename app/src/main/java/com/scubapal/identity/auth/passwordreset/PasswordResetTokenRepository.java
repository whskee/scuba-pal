package com.scubapal.identity.auth.passwordreset;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

import java.time.Instant;
import java.util.Optional;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {
    Optional<PasswordResetToken> findByToken(String token);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select token from PasswordResetToken token join fetch token.user where token.token = :token")
    Optional<PasswordResetToken> findByTokenForUpdate(@Param("token") String token);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
            update PasswordResetToken token
               set token.usedAt = :usedAt
             where token.user.id = :userId
               and token.usedAt is null
            """)
    int markUnusedTokensUsedForUser(@Param("userId") Long userId, @Param("usedAt") Instant usedAt);
}
