CREATE TABLE social.user_follows (
    user_follow_id   BIGSERIAL PRIMARY KEY,
    follower_user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    followed_user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_follows_unique_pair UNIQUE (follower_user_id, followed_user_id),
    CONSTRAINT user_follows_not_self CHECK (follower_user_id <> followed_user_id)
);

-- SEED DATA
INSERT INTO social.user_follows (follower_user_id, followed_user_id)
     VALUES (2, 3),
            (2, 4),
            (3, 2),
            (4, 2),
            (1, 6),
            (2, 6),
            (3, 6),
            (4, 6),
            (5, 6);