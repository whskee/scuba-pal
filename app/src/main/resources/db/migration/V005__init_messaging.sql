CREATE SCHEMA IF NOT EXISTS messaging;

CREATE TABLE messaging.conversations (
    conversation_id BIGSERIAL PRIMARY KEY,
    user_one_id     BIGINT NOT NULL REFERENCES identity.users(user_id),
    user_two_id     BIGINT NOT NULL REFERENCES identity.users(user_id),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT conversations_unique_pair UNIQUE (user_one_id, user_two_id),
    CONSTRAINT conversations_not_self CHECK (user_one_id <> user_two_id)
);

CREATE TABLE IF NOT EXISTS messaging.direct_messages (
    direct_message_id BIGSERIAL PRIMARY KEY,
    conversation_id   BIGINT NOT NULL REFERENCES messaging.conversations(conversation_id),
    sender_user_id    BIGINT NOT NULL REFERENCES identity.users(user_id),
    message_text      VARCHAR(1000) NOT NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at           TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_conversations_user_one ON messaging.conversations(user_one_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user_two ON messaging.conversations(user_two_id);
CREATE INDEX IF NOT EXISTS idx_direct_messages_conversation ON messaging.direct_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_direct_messages_unread ON messaging.direct_messages(conversation_id, sender_user_id, read_at);
