CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS social;
CREATE SCHEMA IF NOT EXISTS dive;
CREATE SCHEMA IF NOT EXISTS certification;
CREATE SCHEMA IF NOT EXISTS notification;

CREATE TABLE identity.roles (
    role_id BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_description VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE identity.users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(60) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id BIGINT NOT NULL REFERENCES identity.roles(role_id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    email_verified_at TIMESTAMP,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE identity.profiles (
    profile_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES identity.users(user_id),
    first_name VARCHAR(80),
    last_name VARCHAR(80),
    phone_number VARCHAR(40),
    city VARCHAR(120),
    state VARCHAR(120),
    country VARCHAR(120),
    date_of_birth DATE,
    visibility_status VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    dive_count INTEGER NOT NULL DEFAULT 0,
    bio VARCHAR(400),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE social.user_follows (
    user_follow_id BIGSERIAL PRIMARY KEY,
    follower_user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    followed_user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_follows_unique_pair UNIQUE (follower_user_id, followed_user_id),
    CONSTRAINT user_follows_not_self CHECK (follower_user_id <> followed_user_id)
);

CREATE TABLE social.posts (
    post_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    caption VARCHAR(500),
    post_type VARCHAR(20) NOT NULL DEFAULT 'TEXT',
    visibility_status VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE social.post_media (
    post_media_id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES social.posts(post_id),
    media_url VARCHAR(500) NOT NULL,
    media_type VARCHAR(20) NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE social.post_likes (
    post_like_id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES social.posts(post_id),
    user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT post_likes_unique_pair UNIQUE (post_id, user_id)
);

CREATE TABLE social.post_comments (
    post_comment_id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES social.posts(post_id),
    user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    comment_text VARCHAR(500) NOT NULL,
    parent_comment_id BIGINT REFERENCES social.post_comments(post_comment_id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE dive.dive_locations (
    dive_location_id BIGSERIAL PRIMARY KEY,
    location_name VARCHAR(180) NOT NULL,
    description VARCHAR(600),
    city VARCHAR(120),
    state VARCHAR(120),
    country VARCHAR(120),
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    difficulty_level VARCHAR(30),
    popularity_score INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dive.dive_shops (
    dive_shop_id BIGSERIAL PRIMARY KEY,
    dive_location_id BIGINT REFERENCES dive.dive_locations(dive_location_id),
    shop_name VARCHAR(180) NOT NULL,
    description VARCHAR(600),
    phone_number VARCHAR(40),
    email VARCHAR(255),
    website_url VARCHAR(255),
    street_address VARCHAR(255),
    city VARCHAR(120),
    state VARCHAR(120),
    country VARCHAR(120),
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE certification.certification_agencies (
    certification_agency_id BIGSERIAL PRIMARY KEY,
    agency_name VARCHAR(120) NOT NULL UNIQUE,
    agency_code VARCHAR(30) NOT NULL UNIQUE,
    website_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE certification.certification_levels (
    certification_level_id BIGSERIAL PRIMARY KEY,
    certification_agency_id BIGINT NOT NULL REFERENCES certification.certification_agencies(certification_agency_id),
    certification_name VARCHAR(120) NOT NULL,
    certification_code VARCHAR(50),
    description VARCHAR(500),
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE certification.user_certifications (
    user_certification_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    certification_level_id BIGINT NOT NULL REFERENCES certification.certification_levels(certification_level_id),
    certification_number VARCHAR(100),
    issued_on DATE,
    expires_on DATE,
    verified_at TIMESTAMP,
    verification_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notification.notifications (
    notification_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES identity.users(user_id),
    title VARCHAR(180) NOT NULL,
    message VARCHAR(500) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_posts_user_id ON social.posts(user_id);
CREATE INDEX idx_post_comments_post_id ON social.post_comments(post_id);
CREATE INDEX idx_post_likes_post_id ON social.post_likes(post_id);
CREATE INDEX idx_dive_locations_city ON dive.dive_locations(city);
CREATE INDEX idx_profiles_city ON identity.profiles(city);
