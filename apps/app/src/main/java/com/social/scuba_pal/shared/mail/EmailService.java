package com.social.scuba_pal.shared.mail;

public interface EmailService {
    void sendPasswordResetEmail(String to, String username, String resetLink);
}
