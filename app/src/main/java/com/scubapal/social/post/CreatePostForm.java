package com.scubapal.social.post;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

import com.scubapal.shared.VisibilityStatus;

@Getter
@Setter
public class CreatePostForm {
    @NotBlank
    private String caption = "";

    private VisibilityStatus visibilityStatus = VisibilityStatus.PUBLIC;

    private String mediaUrl = "";

    public List<String> mediaUrls() {
        return mediaUrl == null || mediaUrl.isBlank() ? List.of() : List.of(mediaUrl.trim());
    }
}
