package com.scubapal.shared.mail;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class ConsoleFallbackEmailService implements EmailService {

    private static final Logger log = LoggerFactory.getLogger(ConsoleFallbackEmailService.class);

    private final ObjectProvider<JavaMailSender> mailSender;
    private final String fromAddress;

    public ConsoleFallbackEmailService(
            ObjectProvider<JavaMailSender> mailSender,
            // @Value("${spring.mail.username:no-reply@scubapal.local}") String fromAddress
            @Value("${app.mail.from:no-reply@scubapal.local}") String fromAddress) {
        this.mailSender = mailSender;
        this.fromAddress = fromAddress;
    }

    @Override
    public void sendPasswordResetEmail(String to, String username, String resetLink) {
        String body = "Hi " + username + ",\n\n"
                + "Use this secure link to reset your Scuba Pal password. The link expires in 30 minutes:\n"
                + resetLink + "\n\n"
                + "For security, Scuba Pal never emails or exposes your current password.\n";

        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null) {
            log.warn("No SMTP mail sender configured. Password reset email for {} would be:\n{}", to, body);
            return;
        }

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(to);
        message.setSubject("Reset your Scuba Pal password");
        message.setText(body);
        sender.send(message);
    }
}
