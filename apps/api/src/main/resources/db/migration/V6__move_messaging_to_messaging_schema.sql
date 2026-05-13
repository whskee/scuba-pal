CREATE SCHEMA IF NOT EXISTS messaging;
ALTER TABLE IF EXISTS social.conversations SET SCHEMA messaging;
ALTER TABLE IF EXISTS social.direct_messages SET SCHEMA messaging;
