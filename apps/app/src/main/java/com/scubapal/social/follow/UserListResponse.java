package com.scubapal.social.follow;

import java.util.List;

import com.scubapal.identity.user.UserView;
import com.scubapal.shared.api.PageMetaResponse;

public record UserListResponse(
        List<UserView> users,
        PageMetaResponse page
) {
}