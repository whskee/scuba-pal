CREATE SCHEMA IF NOT EXISTS notification;

CREATE TABLE notification.notifications (
    notification_id BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES identity.users(user_id),
    title           VARCHAR(180) NOT NULL,
    MESSAGE         VARCHAR(500) NOT NULL,
    is_read         BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX if NOT EXISTS idx_notifications_user_read
ON notification.notifications (
    user_id,
    is_read
);

-- SEED DATA
INSERT INTO notification.notifications (user_id, title, MESSAGE)
     VALUES (2, 'New follower', 'liam_ocean started following you.'),
            (2, 'Weekly tip', 'Safety check: verify your buoyancy compensator inflator before boarding.');