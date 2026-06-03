package com.scubapal.identity.auth.token;

import java.time.Instant;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select token from RefreshToken token join fetch token.user user join fetch user.role where token.tokenHash = :tokenHash")
    Optional<RefreshToken> findByTokenHashForUpdate(@Param("tokenHash") String tokenHash);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
            update RefreshToken token
               set token.revokedAt = :revokedAt,
                   token.revokedByIp = :revokedByIp,
                   token.revokedReason = :revokedReason
             where token.user.id = :userId
               and token.revokedAt is null
            """)
    int revokeActiveTokensForUser(@Param("userId") Long userId,
                                  @Param("revokedAt") Instant revokedAt,
                                  @Param("revokedByIp") String revokedByIp,
                                  @Param("revokedReason") String revokedReason);
}
