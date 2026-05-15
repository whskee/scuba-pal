package com.social.scuba_pal.social.post;

import com.social.scuba_pal.shared.VisibilityStatus;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

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
