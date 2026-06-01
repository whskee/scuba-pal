package com.scubapal.shared.mail;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ConsoleFallbackEmailService implements EmailService {

    private static final Logger log = LoggerFactory.getLogger(ConsoleFallbackEmailService.class);

    private final String fromAddress;

    public ConsoleFallbackEmailService(
            @Value("${app.mail.from:no-reply@scubapal.local}") String fromAddress) {
        this.fromAddress = fromAddress;
    }

    @Override
    public void sendPasswordResetEmail(String to, String username, String resetLink) {
        String body = "Hi " + username + ",\n\n"
                + "Use this secure link to reset your Scuba Pal password. The link expires in 60 minutes:\n"
                + resetLink + "\n\n"
                + "For security, Scuba Pal never emails or exposes your current password.\n";

        log.warn("No SMTP email service configured from {}. Password reset email for {} would be:\n{}", fromAddress, to, body);
    }
}
