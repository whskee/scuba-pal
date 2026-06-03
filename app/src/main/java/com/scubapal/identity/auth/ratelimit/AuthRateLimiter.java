package com.scubapal.identity.auth.ratelimit;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.scubapal.identity.auth.token.TokenHashing;

@Service
public class AuthRateLimiter {

    private static final Duration ENTRY_TTL = Duration.ofHours(2);

    private final AuthRateLimitProperties properties;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final Clock clock;
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    @Autowired
    public AuthRateLimiter(AuthRateLimitProperties properties) {
        this(properties, Clock.systemUTC());
    }

    AuthRateLimiter(AuthRateLimitProperties properties, Clock clock) {
        this.properties = properties;
        this.clock = clock;
    }

    public boolean appliesTo(String method, String path) {
        return policyFor(method, path).isPresent();
    }

    public RateLimitDecision check(String method, String path, String queryString, String remoteAddress, String requestBody) {
        Optional<EndpointPolicy> endpointPolicy = policyFor(method, path);
        if (endpointPolicy.isEmpty()) {
            return RateLimitDecision.allow();
        }

        Instant now = clock.instant();
        cleanup(now);

        EndpointPolicy endpoint = endpointPolicy.get();
        String key = endpoint.name() + ':' + keySubject(endpoint.name(), queryString, remoteAddress, requestBody);
        Bucket bucket = buckets.compute(key, (ignored, existing) -> {
            if (existing == null || !existing.windowStart.plus(endpoint.policy().window()).isAfter(now)) {
                return new Bucket(now, new AtomicInteger(1), now);
            }
            existing.count.incrementAndGet();
            existing.lastSeen = now;
            return existing;
        });

        if (bucket.count.get() > endpoint.policy().capacity()) {
            Instant retryAt = bucket.windowStart.plus(endpoint.policy().window());
            return RateLimitDecision.blocked(Duration.between(now, retryAt).toSeconds());
        }
        return RateLimitDecision.allow();
    }

    private Optional<EndpointPolicy> policyFor(String method, String path) {
        String normalizedMethod = method == null ? "" : method.toUpperCase(Locale.ROOT);
        return switch (normalizedMethod + " " + path) {
            case "POST /api/auth/login" -> Optional.of(new EndpointPolicy("login", properties.login()));
            case "POST /api/auth/register" -> Optional.of(new EndpointPolicy("register", properties.register()));
            case "GET /api/auth/username-available" -> Optional.of(new EndpointPolicy("username-available", properties.usernameAvailability()));
            case "POST /api/auth/forgot-password" -> Optional.of(new EndpointPolicy("forgot-password", properties.forgotPassword()));
            case "POST /api/auth/reset-password" -> Optional.of(new EndpointPolicy("reset-password", properties.resetPassword()));
            case "POST /api/auth/refresh" -> Optional.of(new EndpointPolicy("refresh", properties.refresh()));
            default -> Optional.empty();
        };
    }

    private String keySubject(String endpoint, String queryString, String remoteAddress, String requestBody) {
        String ip = normalize(remoteAddress);
        JsonNode body = parseBody(requestBody);
        return switch (endpoint) {
            case "login" -> normalize(text(body, "username")) + ':' + ip;
            case "register", "username-available" -> ip;
            case "forgot-password" -> normalize(text(body, "emailOrUsername")) + ':' + ip;
            case "reset-password" -> TokenHashing.sha256(text(body, "token")) + ':' + ip;
            case "refresh" -> {
                String tokenHash = TokenHashing.sha256(text(body, "refreshToken"));
                yield (tokenHash.isBlank() ? ip : tokenHash + ':' + ip);
            }
            default -> ip;
        };
    }

    private JsonNode parseBody(String requestBody) {
        if (requestBody == null || requestBody.isBlank()) {
            return objectMapper.nullNode();
        }
        try {
            return objectMapper.readTree(requestBody);
        } catch (Exception ignored) {
            return objectMapper.nullNode();
        }
    }

    private String text(JsonNode body, String fieldName) {
        JsonNode field = body.get(fieldName);
        return field == null || field.isNull() ? "" : field.asText("");
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
    }

    private void cleanup(Instant now) {
        buckets.entrySet().removeIf(entry -> entry.getValue().lastSeen.plus(ENTRY_TTL).isBefore(now));
    }

    private record EndpointPolicy(String name, AuthRateLimitProperties.Policy policy) {
    }

    public record RateLimitDecision(boolean allowed, long retryAfterSeconds) {
        static RateLimitDecision allow() {
            return new RateLimitDecision(true, 0);
        }

        static RateLimitDecision blocked(long retryAfterSeconds) {
            return new RateLimitDecision(false, Math.max(1, retryAfterSeconds));
        }
    }

    private static final class Bucket {
        private final Instant windowStart;
        private final AtomicInteger count;
        private Instant lastSeen;

        private Bucket(Instant windowStart, AtomicInteger count, Instant lastSeen) {
            this.windowStart = windowStart;
            this.count = count;
            this.lastSeen = lastSeen;
        }
    }
}
