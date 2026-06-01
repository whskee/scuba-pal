package com.scubapal.social.follow;

import java.util.List;

import com.scubapal.identity.user.PublicUserView;
import com.scubapal.shared.api.PageMetaResponse;

public record UserListResponse(
        List<PublicUserView> users,
        PageMetaResponse page
) {
}
