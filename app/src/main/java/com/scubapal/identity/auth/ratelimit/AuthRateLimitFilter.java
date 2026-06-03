package com.scubapal.identity.auth.ratelimit;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class AuthRateLimitFilter extends OncePerRequestFilter {

    private static final String PROBLEM_JSON = """
            {"type":"https://api.scubapal.com/problems/429","title":"Too many requests","status":429,"detail":"Please wait before trying again."}
            """;

    private final AuthRateLimiter rateLimiter;

    public AuthRateLimitFilter(AuthRateLimiter rateLimiter) {
        this.rateLimiter = rateLimiter;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !rateLimiter.appliesTo(request.getMethod(), pathWithinApplication(request));
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        CachedBodyRequest wrappedRequest = new CachedBodyRequest(request);
        AuthRateLimiter.RateLimitDecision decision = rateLimiter.check(
                request.getMethod(),
                pathWithinApplication(request),
                request.getQueryString(),
                request.getRemoteAddr(),
                wrappedRequest.bodyAsString());

        if (!decision.allowed()) {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setHeader(HttpHeaders.RETRY_AFTER, Long.toString(decision.retryAfterSeconds()));
            response.setContentType("application/problem+json");
            response.getWriter().write(PROBLEM_JSON);
            return;
        }

        filterChain.doFilter(wrappedRequest, response);
    }

    private String pathWithinApplication(HttpServletRequest request) {
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        if (contextPath == null || contextPath.isBlank()) {
            return uri;
        }
        return uri.substring(contextPath.length());
    }

    private static final class CachedBodyRequest extends HttpServletRequestWrapper {
        private final byte[] body;

        private CachedBodyRequest(HttpServletRequest request) throws IOException {
            super(request);
            this.body = StreamUtils.copyToByteArray(request.getInputStream());
        }

        private String bodyAsString() {
            return new String(body, StandardCharsets.UTF_8);
        }

        @Override
        public ServletInputStream getInputStream() {
            ByteArrayInputStream input = new ByteArrayInputStream(body);
            return new ServletInputStream() {
                @Override
                public boolean isFinished() {
                    return input.available() == 0;
                }

                @Override
                public boolean isReady() {
                    return true;
                }

                @Override
                public void setReadListener(ReadListener readListener) {
                    throw new UnsupportedOperationException("Async request body reads are not supported");
                }

                @Override
                public int read() {
                    return input.read();
                }
            };
        }

        @Override
        public BufferedReader getReader() {
            return new BufferedReader(new InputStreamReader(getInputStream(), StandardCharsets.UTF_8));
        }
    }
}
