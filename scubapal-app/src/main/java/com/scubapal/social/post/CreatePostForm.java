package com.scubapal.social.post;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

import com.scubapal.shared.VisibilityStatus;

@Getter
@Setter
public class CreatePostForm {
    @NotBlank
    @Size(max = 500)
    private String caption = "";

    private VisibilityStatus visibilityStatus = VisibilityStatus.PUBLIC;

    @Size(max = 500)
    private String mediaUrl = "";

    public List<String> mediaUrls() {
        return mediaUrl == null || mediaUrl.isBlank() ? List.of() : List.of(mediaUrl.trim());
    }
}
