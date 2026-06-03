ALTER TABLE identity.refresh_tokens
    ADD COLUMN revoked_reason VARCHAR(64);
