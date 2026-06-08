package com.scubapal.shared.mail;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.mail.javamail.JavaMailSender;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class EmailServiceSelectionTest {

    @Test
    void smtpEmailServiceIsUsedWhenMailIsEnabledInDev() {
        new ApplicationContextRunner()
                .withUserConfiguration(SmtpEmailService.class, ConsoleFallbackEmailService.class)
                .withBean(JavaMailSender.class, () -> mock(JavaMailSender.class))
                .withPropertyValues(
                        "spring.profiles.active=dev",
                        "app.mail.enabled=true",
                        "app.mail.from=no-reply@scubapal.local"
                )
                .run(context -> {
                    assertThat(context).hasSingleBean(EmailService.class);
                    assertThat(context.getBean(EmailService.class)).isInstanceOf(SmtpEmailService.class);
                });
    }

    @Test
    void consoleFallbackIsUsedWhenMailIsDisabledInDev() {
        new ApplicationContextRunner()
                .withUserConfiguration(SmtpEmailService.class, ConsoleFallbackEmailService.class)
                .withPropertyValues(
                        "spring.profiles.active=dev",
                        "app.mail.enabled=false"
                )
                .run(context -> {
                    assertThat(context).hasSingleBean(EmailService.class);
                    assertThat(context.getBean(EmailService.class)).isInstanceOf(ConsoleFallbackEmailService.class);
                });
    }
}
