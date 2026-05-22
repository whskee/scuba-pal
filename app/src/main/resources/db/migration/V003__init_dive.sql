CREATE SCHEMA IF NOT EXISTS dive;

CREATE TABLE dive.dive_locations (
    dive_location_id BIGSERIAL PRIMARY KEY,
    location_name    VARCHAR(180) NOT NULL,
    description      VARCHAR(600),
    city             VARCHAR(120),
    state            VARCHAR(120),
    country          VARCHAR(120),
    latitude         NUMERIC(10, 7),
    longitude        NUMERIC(10, 7),
    difficulty_level VARCHAR(30),
    popularity_score INTEGER NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dive.dive_shops (
    dive_shop_id     BIGSERIAL PRIMARY KEY,
    dive_location_id BIGINT REFERENCES dive.dive_locations(dive_location_id),
    shop_name        VARCHAR(180) NOT NULL,
    description      VARCHAR(600),
    phone_number     VARCHAR(40),
    email            VARCHAR(255),
    website_url      VARCHAR(255),
    street_address   VARCHAR(255),
    city             VARCHAR(120),
    state            VARCHAR(120),
    country          VARCHAR(120),
    latitude         NUMERIC(10, 7),
    longitude        NUMERIC(10, 7),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dive_locations_city ON dive.dive_locations (city);

-- SEED DATA
INSERT INTO dive.dive_locations (location_name, description, city, state, country, latitude, longitude, difficulty_level, popularity_score)
     VALUES ('La Jolla Shores', 'Easy shore entries and kelp forests ideal for all levels.', 'San Diego', 'California', 'USA', 32.8507000, -117.2721000, 'BEGINNER', 89),
            ('Molokini Crater', 'Clear water crater with reef walls and abundant pelagic life.', 'Maui', 'Hawaii', 'USA', 20.6333000, -156.4963000, 'INTERMEDIATE', 95),
            ('USS Spiegel Grove', 'Legendary wreck dive with dramatic structure and marine growth.', 'Key Largo', 'Florida', 'USA', 25.0421000, -80.2970000, 'ADVANCED', 91),
            ('Blue Heron Bridge', 'Macro life hotspot with calm water and frequent training dives.', 'West Palm Beach', 'Florida', 'USA', 26.7865000, -80.0491000, 'BEGINNER', 87);

INSERT INTO dive.dive_shops (dive_location_id, shop_name, description, phone_number, email, website_url, street_address, city, state, country, latitude, longitude)
     VALUES (1, 'Pacific Kelp Divers', 'Guided shore and boat dives in San Diego.', '+1-619-555-0120', 'hello@pacifickelp.com', 'https://pacifickelp.example', '120 Coastline Dr', 'San Diego', 'California', 'USA', 32.8579000, -117.2572000),
            (3, 'Blue Horizon Charters', 'Technical and recreational trips in the Florida Keys.', '+1-305-555-0142', 'contact@bluehorizon.com', 'https://bluehorizon.example', '88 Harbor Way', 'Key Largo', 'Florida', 'USA', 25.0873000, -80.4473000);