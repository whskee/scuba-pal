CREATE TABLE identity.refresh_tokens (
    refresh_token_id       BIGSERIAL PRIMARY KEY,
    user_id                BIGINT NOT NULL REFERENCES identity.users(user_id),
    token_hash             VARCHAR(64) NOT NULL UNIQUE,
    expires_at             TIMESTAMPTZ NOT NULL,
    revoked_at             TIMESTAMPTZ,
    replaced_by_token_hash VARCHAR(64),
    created_by_ip          VARCHAR(64),
    revoked_by_ip          VARCHAR(64),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_refresh_tokens_user_id ON identity.refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires_at ON identity.refresh_tokens(expires_at);
CREATE INDEX idx_refresh_tokens_active_user
    ON identity.refresh_tokens(user_id)
    WHERE revoked_at IS NULL;
