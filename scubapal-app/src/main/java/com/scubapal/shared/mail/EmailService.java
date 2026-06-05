package com.scubapal.shared.mail;

public interface EmailService {
    void sendPasswordResetEmail(String to, String username, String resetLink);
}
