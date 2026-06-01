package com.scubapal.shared.security;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.concurrent.atomic.AtomicInteger;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

class AuthRateLimitFilterTest {

    private static final Clock FIXED_CLOCK = Clock.fixed(Instant.parse("2026-06-01T00:00:00Z"), ZoneOffset.UTC);

    @Test
    void limitsApiRegisterAttempts() throws Exception {
        AuthRateLimitFilter filter = new AuthRateLimitFilter(FIXED_CLOCK);
        AtomicInteger downstreamCalls = new AtomicInteger();
        MockHttpServletResponse response = new MockHttpServletResponse();

        for (int attempt = 0; attempt < 21; attempt++) {
            response = new MockHttpServletResponse();
            filter.doFilterInternal(request("POST", "/api/auth/register", "203.0.113.10"), response, countingChain(downstreamCalls));
        }

        assertEquals(20, downstreamCalls.get());
        assertEquals(HttpStatus.TOO_MANY_REQUESTS.value(), response.getStatus());
        assertEquals("application/problem+json", response.getContentType());
    }

    @Test
    void ignoresSpoofedForwardedForHeaderWhenBucketing() throws Exception {
        AuthRateLimitFilter filter = new AuthRateLimitFilter(FIXED_CLOCK);
        AtomicInteger downstreamCalls = new AtomicInteger();
        MockHttpServletResponse response = new MockHttpServletResponse();

        for (int attempt = 0; attempt < 21; attempt++) {
            MockHttpServletRequest request = request("POST", "/api/auth/login", "203.0.113.20");
            request.addHeader("X-Forwarded-For", "198.51.100." + attempt);
            response = new MockHttpServletResponse();
            filter.doFilterInternal(request, response, countingChain(downstreamCalls));
        }

        assertEquals(20, downstreamCalls.get());
        assertEquals(HttpStatus.TOO_MANY_REQUESTS.value(), response.getStatus());
    }

    private MockHttpServletRequest request(String method, String path, String remoteAddr) {
        MockHttpServletRequest request = new MockHttpServletRequest(method, path);
        request.setRemoteAddr(remoteAddr);
        return request;
    }

    private FilterChain countingChain(AtomicInteger downstreamCalls) {
        return (request, response) -> downstreamCalls.incrementAndGet();
    }
}
