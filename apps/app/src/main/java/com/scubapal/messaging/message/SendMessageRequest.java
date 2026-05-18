package com.scubapal.messaging.message;

import jakarta.validation.constraints.NotBlank;

public record SendMessageRequest(@NotBlank String messageText) {
}