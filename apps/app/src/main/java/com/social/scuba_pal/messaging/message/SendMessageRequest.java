package com.social.scuba_pal.messaging.message;

import jakarta.validation.constraints.NotBlank;

public record SendMessageRequest(@NotBlank String messageText) {
}