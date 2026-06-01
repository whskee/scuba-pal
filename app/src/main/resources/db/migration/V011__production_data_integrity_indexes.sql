CREATE UNIQUE INDEX IF NOT EXISTS users_email_lower_uq
    ON identity.users (lower(email))
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS users_username_lower_uq
    ON identity.users (lower(username))
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS post_likes_post_user_uq
    ON social.post_likes (post_id, user_id);

CREATE UNIQUE INDEX IF NOT EXISTS user_follows_follower_followed_uq
    ON social.user_follows (follower_user_id, followed_user_id);

CREATE UNIQUE INDEX IF NOT EXISTS conversations_user_pair_uq
    ON messaging.conversations (user_one_id, user_two_id);
