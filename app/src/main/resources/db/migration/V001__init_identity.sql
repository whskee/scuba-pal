CREATE SCHEMA IF NOT EXISTS identity;

CREATE TABLE identity.roles (
    role_id          BIGSERIAL PRIMARY KEY,
    role_name        VARCHAR(50) NOT NULL UNIQUE,
    role_description VARCHAR(255),
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE identity.users (
    user_id           BIGSERIAL PRIMARY KEY,
    email             VARCHAR(255) NOT NULL UNIQUE,
    username          VARCHAR(60) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    role_id           BIGINT NOT NULL REFERENCES identity.roles(role_id),
    is_active         BOOLEAN NOT NULL DEFAULT true,
    email_verified_at TIMESTAMP,
    last_login_at     TIMESTAMP,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMP
);

CREATE TABLE identity.profiles (
    profile_id        BIGSERIAL PRIMARY KEY,
    user_id           BIGINT NOT NULL UNIQUE REFERENCES identity.users(user_id),
    profile_image_url VARCHAR(500),
    first_name        VARCHAR(80),
    last_name         VARCHAR(80),
    gender            VARCHAR(20),
    phone_number      VARCHAR(40),
    city              VARCHAR(120),
    state             VARCHAR(120),
    country           VARCHAR(120),
    date_of_birth     DATE,
    visibility_status VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    dive_count        INTEGER NOT NULL DEFAULT 0,
    bio               VARCHAR(400),
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE identity.password_reset_tokens (
    password_reset_token_id BIGSERIAL PRIMARY KEY,
    user_id                 BIGINT NOT NULL REFERENCES identity.users(user_id),
    token                   VARCHAR(120) NOT NULL UNIQUE,
    expires_at              TIMESTAMP NOT NULL,
    used_at                 TIMESTAMP,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_profiles_city ON identity.profiles(city);
CREATE INDEX idx_password_reset_tokens_token ON identity.password_reset_tokens(token);
CREATE INDEX idx_password_reset_tokens_user_id ON identity.password_reset_tokens (user_id);


-- SEED DATA
INSERT INTO identity.roles (role_name, role_description)
     VALUES ('admin', 'Platform Administrator'),
            ('user', 'Default diver account'),
            ('shop_owner', 'Dive Shop Manager'),
            ('moderator', 'Community Moderator');

INSERT INTO identity.users (email, username, password_hash, role_id, email_verified_at, last_login_at)
     VALUES ('admin@scubapal.app', 'admin', '$2a$10$lm50JthtxmqRaf6ohIDU.eR9bx.RBC5Ex54UjMghUd43V/Am4DgC2', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
            ('maya@scubapal.app', 'maya_dives', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
            ('liam@scubapal.app', 'liam_ocean', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
            ('sara@scubapal.app', 'sara_reef', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
            ('shop@bluehorizon.com', 'blue_horizon', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
            ('chinmayabidkar@hotmail.com', 'cbidkar', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
            ('joule_thief@gmail.com', 'joule_thief', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO identity.profiles (user_id, first_name, last_name, city, state, country, visibility_status, dive_count, bio)
     VALUES (1, 'Admin', 'User', 'Miami', 'Florida', 'USA', 'PUBLIC', 320, 'Keeping the reef-friendly community running.'),
            (2, 'Maya', 'Patel', 'San Diego', 'California', 'USA', 'PUBLIC', 128, 'Underwater photographer and night diver.'),
            (3, 'Liam', 'Chen', 'Honolulu', 'Hawaii', 'USA', 'PUBLIC', 203, 'Wreck diving specialist and rescue diver.'),
            (4, 'Sara', 'Martinez', 'Key Largo', 'Florida', 'USA', 'PUBLIC', 98, 'Open water instructor, always chasing clear visibility.'),
            (5, 'Blue', 'Horizon', 'Key Largo', 'Florida', 'USA', 'PUBLIC', 0, 'Daily guided charters and equipment rental.'),
            (6, 'Chinmaya', 'Bidkar', 'Phoenix', 'Arizona', 'USA', 'PUBLIC', 1, 'Passionate about life. Just getting started with diving!'),
            (7, 'Joule', 'Thief', 'San Francisco', 'California', 'USA', 'PUBLIC', 45, 'I steal energy');

-- UPDATE users SET avatar_url = 'profile-images/awkward-face.jpeg' WHERE user_id = 1;
UPDATE identity.profiles SET profile_image_url = 'media/profile-images/greek-boy.jpeg' WHERE user_id = 1;
UPDATE identity.profiles SET profile_image_url = 'media/profile-images/some-scenery.jpeg' WHERE user_id = 2;
UPDATE identity.profiles SET profile_image_url = 'media/profile-images/awkward-face.jpeg' WHERE user_id = 3;
UPDATE identity.profiles SET profile_image_url = 'media/profile-images/classy-chinmaya.jpeg' WHERE user_id = 6;
UPDATE identity.profiles SET profile_image_url = 'media/profile-images/joule-thief-cat.jpeg' WHERE user_id = 7;