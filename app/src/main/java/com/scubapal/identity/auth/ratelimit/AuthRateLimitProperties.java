package com.scubapal.identity.auth.ratelimit;

import java.time.Duration;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.security.auth-rate-limit")
public record AuthRateLimitProperties(
        Policy login,
        Policy register,
        Policy usernameAvailability,
        Policy forgotPassword,
        Policy resetPassword,
        Policy refresh
) {
    public AuthRateLimitProperties {
        login = Policy.withDefaults(login, 5, Duration.ofMinutes(1));
        register = Policy.withDefaults(register, 5, Duration.ofHours(1));
        usernameAvailability = Policy.withDefaults(usernameAvailability, 20, Duration.ofMinutes(1));
        forgotPassword = Policy.withDefaults(forgotPassword, 3, Duration.ofMinutes(15));
        resetPassword = Policy.withDefaults(resetPassword, 5, Duration.ofMinutes(15));
        refresh = Policy.withDefaults(refresh, 20, Duration.ofMinutes(1));
    }

    public record Policy(Integer capacity, Duration window) {
        static Policy withDefaults(Policy policy, int defaultCapacity, Duration defaultWindow) {
            if (policy == null) {
                return new Policy(defaultCapacity, defaultWindow);
            }
            Integer capacity = policy.capacity();
            Duration window = policy.window();
            return new Policy(
                    capacity == null || capacity < 1 ? defaultCapacity : capacity,
                    window == null || window.isZero() || window.isNegative() ? defaultWindow : window);
        }
    }
}
