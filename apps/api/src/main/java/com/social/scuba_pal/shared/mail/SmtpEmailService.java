package com.social.scuba_pal.shared.mail;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailSendException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SmtpEmailService {

    private final JavaMailSender mailSender;

    @Value("${app.mail.from}")
    private String from;

    public void sendPasswordResetEmail(String to, String displayName, String resetLink) {
        try {
            MimeMessage message = mailSender.createMimeMessage();

            MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
            helper.setFrom(from);
            helper.setTo(to);
            helper.setSubject("Reset your Scuba Pal password");

            helper.setText("""
                    Hi %s,

                    Use this secure link to reset your Scuba Pal password.
                    The link expires in 30 minutes:

                    %s

                    If you did not request this, you can ignore this email.

                    - Scuba Pal
                    """.formatted(displayName, resetLink), false);

            mailSender.send(message);
        } catch (MessagingException | MailSendException ex) {
            throw new IllegalStateException("Failed to send password reset email", ex);
        }
    }
}