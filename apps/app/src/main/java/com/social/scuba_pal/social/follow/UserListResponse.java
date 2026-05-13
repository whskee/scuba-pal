package com.social.scuba_pal.social.follow;

import com.social.scuba_pal.identity.user.UserView;
import com.social.scuba_pal.shared.api.PageMetaResponse;

import java.util.List;

public record UserListResponse(
        List<UserView> users,
        PageMetaResponse page
) {
}