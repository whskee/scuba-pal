ALTER TABLE identity.profiles ADD COLUMN IF NOT EXISTS profile_image_url VARCHAR(500);

CREATE TABLE IF NOT EXISTS social.conversations (
    conversation_id BIGSERIAL PRIMARY KEY,
    user_one_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    user_two_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT conversations_unique_pair UNIQUE (user_one_id, user_two_id),
    CONSTRAINT conversations_not_self CHECK (user_one_id <> user_two_id)
);

CREATE TABLE IF NOT EXISTS social.direct_messages (
    direct_message_id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES social.conversations(conversation_id),
    sender_user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    message_text VARCHAR(1000) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_conversations_user_one ON social.conversations(user_one_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user_two ON social.conversations(user_two_id);
CREATE INDEX IF NOT EXISTS idx_direct_messages_conversation ON social.direct_messages(conversation_id);
