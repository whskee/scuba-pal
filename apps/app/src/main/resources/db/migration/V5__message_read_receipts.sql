ALTER TABLE social.direct_messages ADD COLUMN IF NOT EXISTS read_at TIMESTAMP;
CREATE INDEX IF NOT EXISTS idx_direct_messages_unread ON social.direct_messages(conversation_id, sender_user_id, read_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notification.notifications(user_id, is_read);
