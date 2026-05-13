package com.social.scuba_pal.social.comment;

import jakarta.validation.constraints.NotBlank;

public record CreateCommentRequest(@NotBlank String commentText) {
}
