package com.scubapal.shared.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class AuthRateLimitFilter extends OncePerRequestFilter {

    private static final int MAX_ATTEMPTS = 20;
    private static final Duration WINDOW = Duration.ofMinutes(1);
    private static final Duration ENTRY_TTL = Duration.ofMinutes(5);
    private static final Set<String> POST_LIMITED_PATHS = Set.of(
            "/api/auth/login",
            "/api/auth/register",
            "/api/auth/forgot-password",
            "/api/auth/reset-password",
            "/api/auth/refresh",
            "/api/auth/logout",
            "/login",
            "/register",
            "/forgot-password",
            "/reset-password"
    );
    private static final Set<String> GET_LIMITED_PATHS = Set.of(
            "/api/auth/username-available"
    );

    private final Clock clock;
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    public AuthRateLimitFilter() {
        this(Clock.systemUTC());
    }

    AuthRateLimitFilter(Clock clock) {
        this.clock = clock;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return switch (request.getMethod()) {
            case "POST" -> !POST_LIMITED_PATHS.contains(request.getRequestURI());
            case "GET" -> !GET_LIMITED_PATHS.contains(request.getRequestURI());
            default -> true;
        };
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        Instant now = clock.instant();
        cleanup(now);

        Bucket bucket = buckets.compute(key(request), (ignored, existing) -> {
            if (existing == null || existing.windowStart.plus(WINDOW).isBefore(now)) {
                return new Bucket(now, new AtomicInteger(1), now);
            }
            existing.count.incrementAndGet();
            existing.lastSeen = now;
            return existing;
        });

        if (bucket.count.get() > MAX_ATTEMPTS) {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/problem+json");
            response.getWriter().write("""
                    {"type":"https://api.scubapal.com/problems/429","title":"Too many requests","status":429,"detail":"Please wait before trying again."}
                    """);
            return;
        }

        filterChain.doFilter(request, response);
    }

    private String key(HttpServletRequest request) {
        return clientIp(request) + ':' + request.getRequestURI();
    }

    private String clientIp(HttpServletRequest request) {
        return request.getRemoteAddr();
    }

    private void cleanup(Instant now) {
        buckets.entrySet().removeIf(entry -> entry.getValue().lastSeen.plus(ENTRY_TTL).isBefore(now));
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
