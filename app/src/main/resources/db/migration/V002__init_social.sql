CREATE TABLE social.user_follows (
    user_follow_id   BIGSERIAL PRIMARY KEY,
    follower_user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    followed_user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_follows_unique_pair UNIQUE (follower_user_id, followed_user_id),
    CONSTRAINT user_follows_not_self CHECK (follower_user_id <> followed_user_id)
);

CREATE TABLE social.posts (
    post_id           BIGSERIAL PRIMARY KEY,
    user_id           BIGINT NOT NULL REFERENCES identity.users(user_id),
    caption           VARCHAR(500),
    post_type         VARCHAR(20) NOT NULL DEFAULT 'TEXT',
    visibility_status VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    created_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMPTZ
);

CREATE TABLE social.post_media (
    post_media_id BIGSERIAL PRIMARY KEY,
    post_id       BIGINT NOT NULL REFERENCES social.posts(post_id),
    media_url     VARCHAR(500) NOT NULL,
    media_type    VARCHAR(20) NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE social.post_likes (
    post_like_id BIGSERIAL PRIMARY KEY,
    post_id      BIGINT NOT NULL REFERENCES social.posts(post_id),
    user_id      BIGINT NOT NULL REFERENCES identity.users(user_id),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT post_likes_unique_pair UNIQUE (post_id, user_id)
);

CREATE TABLE social.post_comments (
    post_comment_id   BIGSERIAL PRIMARY KEY,
    post_id           BIGINT NOT NULL REFERENCES social.posts(post_id),
    user_id           BIGINT NOT NULL REFERENCES identity.users(user_id),
    comment_text      VARCHAR(500) NOT NULL,
    parent_comment_id BIGINT REFERENCES social.post_comments(post_comment_id),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMPTZ
);

CREATE INDEX idx_posts_user_id ON social.posts (user_id);
CREATE INDEX idx_post_comments_post_id ON social.post_comments (post_id);
CREATE INDEX idx_post_likes_post_id ON social.post_likes (post_id);

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

INSERT INTO social.posts (user_id, caption, post_type, visibility_status)
     VALUES (2, 'Morning dive at La Jolla was unreal. Leopard sharks and crystal visibility.', 'TEXT', 'PUBLIC'),
            (3, 'Logged my 200th dive today at Molokini Crater. Still speechless.', 'TEXT', 'PUBLIC'),
            (4, 'Anyone heading to Key Largo this weekend for wreck dives?', 'TEXT', 'PUBLIC'),
            (6, 'Sometimes, I stare at rocks and wonder...', 'TEXT', 'PUBLIC'),
            (6, 'The secret to happiness is loving everything you hate.', 'TEXT', 'PUBLIC'),
            (7, 'Guess what!', 'TEXT', 'PUBLIC');

INSERT INTO social.post_media (post_id, media_url, media_type)
     VALUES (1, '/media/post-images/la-jolla-dive.jpeg', 'IMAGE'),
            (2, '/media/post-images/molokini-crater-whale.jpeg', 'IMAGE'),
            (3, '/media/post-images/key-largo-wreck.jpeg', 'IMAGE'),
            (4, '/media/post-images/colorful-rock.jpg', 'IMAGE'),
            (5, '/media/post-images/happiness-pills.jpeg', 'IMAGE'),
            (6, '/media/post-images/binary-fu.jpeg', 'IMAGE');

INSERT INTO social.post_likes (post_id, user_id)
     VALUES (1, 3),
            (1, 4),
            (2, 2),
            (3, 2),
            (4, 1),
            (4, 2),
            (4, 3),
            (4, 4),
            (4, 5),
            (5, 1),
            (5, 2),
            (5, 3),
            (5, 4),
            (5, 5);

INSERT INTO social.post_comments (post_id, user_id, comment_text)
     VALUES (1, 3, 'That visibility report just made my day.'),
            (1, 4, 'Planning to go there next week!'),
            (2, 2, 'Huge milestone. Congrats!');