CREATE TABLE IF NOT EXISTS social.post_media
    (
        post_media_id BIGSERIAL PRIMARY KEY                           ,
        post_id       BIGINT NOT NULL REFERENCES social.posts(post_id),
        media_url     VARCHAR(500) NOT NULL                           ,
        media_type    VARCHAR(20) NOT NULL                            ,
        display_order INTEGER NOT NULL DEFAULT 0                      ,
        created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
;

CREATE INDEX IF NOT EXISTS idx_post_media_post_id
ON social.post_media
    (
        post_id
    )
;
