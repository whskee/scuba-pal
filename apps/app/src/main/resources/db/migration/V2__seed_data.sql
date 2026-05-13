INSERT INTO identity.roles (role_name, role_description)
VALUES
('admin', 'Platform administrator'),
('user', 'Default diver account'),
('shop_owner', 'Dive shop manager'),
('moderator', 'Community moderator');

INSERT INTO identity.users (email, username, password_hash, role_id, email_verified_at, last_login_at)
VALUES
('admin@scubapal.app', 'admin', '$2a$10$lm50JthtxmqRaf6ohIDU.eR9bx.RBC5Ex54UjMghUd43V/Am4DgC2', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('maya@scubapal.app', 'maya_dives', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('liam@scubapal.app', 'liam_ocean', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('sara@scubapal.app', 'sara_reef', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('shop@bluehorizon.com', 'blue_horizon', '$2a$10$jr//Knf/Xq3GHubZGk2sIuU3tUhIEC.KeVkqwqc0mbCkMtqQnuKLa', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO identity.profiles (user_id, first_name, last_name, city, state, country, visibility_status, dive_count, bio)
VALUES
(1, 'Admin', 'User', 'Miami', 'Florida', 'USA', 'PUBLIC', 320, 'Keeping the reef-friendly community running.'),
(2, 'Maya', 'Patel', 'San Diego', 'California', 'USA', 'PUBLIC', 128, 'Underwater photographer and night diver.'),
(3, 'Liam', 'Chen', 'Honolulu', 'Hawaii', 'USA', 'PUBLIC', 203, 'Wreck diving specialist and rescue diver.'),
(4, 'Sara', 'Martinez', 'Key Largo', 'Florida', 'USA', 'PUBLIC', 98, 'Open water instructor, always chasing clear visibility.'),
(5, 'Blue', 'Horizon', 'Key Largo', 'Florida', 'USA', 'PUBLIC', 0, 'Daily guided charters and equipment rental.');

INSERT INTO social.user_follows (follower_user_id, followed_user_id)
VALUES
(2, 3),
(2, 4),
(3, 2),
(4, 2);

INSERT INTO dive.dive_locations (location_name, description, city, state, country, latitude, longitude, difficulty_level, popularity_score)
VALUES
('La Jolla Shores', 'Easy shore entries and kelp forests ideal for all levels.', 'San Diego', 'California', 'USA', 32.8507000, -117.2721000, 'BEGINNER', 89),
('Molokini Crater', 'Clear water crater with reef walls and abundant pelagic life.', 'Maui', 'Hawaii', 'USA', 20.6333000, -156.4963000, 'INTERMEDIATE', 95),
('USS Spiegel Grove', 'Legendary wreck dive with dramatic structure and marine growth.', 'Key Largo', 'Florida', 'USA', 25.0421000, -80.2970000, 'ADVANCED', 91),
('Blue Heron Bridge', 'Macro life hotspot with calm water and frequent training dives.', 'West Palm Beach', 'Florida', 'USA', 26.7865000, -80.0491000, 'BEGINNER', 87);

INSERT INTO dive.dive_shops (dive_location_id, shop_name, description, phone_number, email, website_url, street_address, city, state, country, latitude, longitude)
VALUES
(1, 'Pacific Kelp Divers', 'Guided shore and boat dives in San Diego.', '+1-619-555-0120', 'hello@pacifickelp.com', 'https://pacifickelp.example', '120 Coastline Dr', 'San Diego', 'California', 'USA', 32.8579000, -117.2572000),
(3, 'Blue Horizon Charters', 'Technical and recreational trips in the Florida Keys.', '+1-305-555-0142', 'contact@bluehorizon.com', 'https://bluehorizon.example', '88 Harbor Way', 'Key Largo', 'Florida', 'USA', 25.0873000, -80.4473000);

INSERT INTO social.posts (user_id, caption, post_type, visibility_status)
VALUES
(2, 'Morning dive at La Jolla was unreal. Leopard sharks and crystal visibility.', 'TEXT', 'PUBLIC'),
(3, 'Logged my 200th dive today at Molokini Crater. Still speechless.', 'TEXT', 'PUBLIC'),
(4, 'Anyone heading to Key Largo this weekend for wreck dives?', 'TEXT', 'PUBLIC');

INSERT INTO social.post_likes (post_id, user_id)
VALUES
(1, 3),
(1, 4),
(2, 2),
(3, 2);

INSERT INTO social.post_comments (post_id, user_id, comment_text)
VALUES
(1, 3, 'That visibility report just made my day.'),
(1, 4, 'Planning to go there next week!'),
(2, 2, 'Huge milestone. Congrats!');

INSERT INTO certification.certification_agencies (agency_name, agency_code, website_url)
VALUES
('PADI', 'PADI', 'https://www.padi.com'),
('SSI', 'SSI', 'https://www.divessi.com'),
('NAUI', 'NAUI', 'https://www.naui.org');

INSERT INTO certification.certification_levels (certification_agency_id, certification_name, certification_code, description, display_order)
VALUES
(1, 'Open Water Diver', 'OWD', 'Foundational recreational diver certification.', 1),
(1, 'Advanced Open Water Diver', 'AOWD', 'Builds depth and navigation experience.', 2),
(2, 'Open Water Diver', 'OWD', 'SSI entry-level scuba certification.', 1);

INSERT INTO certification.user_certifications (user_id, certification_level_id, certification_number, issued_on, verification_status, verified_at)
VALUES
(2, 2, 'PADI-AOW-23981', DATE '2023-06-10', 'VERIFIED', CURRENT_TIMESTAMP),
(3, 2, 'PADI-AOW-44802', DATE '2022-11-03', 'VERIFIED', CURRENT_TIMESTAMP),
(4, 1, 'PADI-OW-99304', DATE '2024-02-18', 'VERIFIED', CURRENT_TIMESTAMP);

INSERT INTO notification.notifications (user_id, title, message)
VALUES
(2, 'New follower', 'liam_ocean started following you.'),
(2, 'Weekly tip', 'Safety check: verify your buoyancy compensator inflator before boarding.');
