CREATE SCHEMA IF NOT EXISTS certification;

CREATE TABLE certification.certification_agencies (
    certification_agency_id BIGSERIAL PRIMARY KEY,
    agency_name             VARCHAR(120) NOT NULL UNIQUE,
    agency_code             VARCHAR(30) NOT NULL UNIQUE,
    website_url             VARCHAR(255),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE certification.certification_levels (
    certification_level_id  BIGSERIAL PRIMARY KEY,
    certification_agency_id BIGINT NOT NULL REFERENCES certification.certification_agencies(certification_agency_id),
    certification_name      VARCHAR(120) NOT NULL,
    certification_code      VARCHAR(50),
    description             VARCHAR(500),
    display_order           INTEGER NOT NULL DEFAULT 0,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE certification.user_certifications (
    user_certification_id  BIGSERIAL PRIMARY KEY,
    user_id                BIGINT NOT NULL REFERENCES identity.users(user_id),
    certification_level_id BIGINT NOT NULL REFERENCES certification.certification_levels(certification_level_id),
    certification_number   VARCHAR(100),
    issued_on              DATE,
    expires_on             DATE,
    verified_at            TIMESTAMPTZ,
    verification_status    VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- SEED DATA
INSERT INTO certification.certification_agencies (agency_name, agency_code, website_url)
     VALUES ('PADI', 'PADI', 'https://www.padi.com'),
            ('SSI', 'SSI', 'https://www.divessi.com'),
            ('NAUI', 'NAUI', 'https://www.naui.org');

INSERT INTO certification.certification_levels (certification_agency_id, certification_name, certification_code, description, display_order)
     VALUES (1, 'Open Water Diver', 'OWD', 'Foundational recreational diver certification.', 1),
            (1, 'Advanced Open Water Diver', 'AOWD', 'Builds depth and navigation experience.', 2),
            (2, 'Open Water Diver', 'OWD', 'SSI entry-level scuba certification.', 1);

INSERT INTO certification.user_certifications (user_id, certification_level_id, certification_number, issued_on, verification_status, verified_at)
     VALUES (2, 2, 'PADI-AOW-23981', DATE '2023-06-10', 'VERIFIED', CURRENT_TIMESTAMP),
            (3, 2, 'PADI-AOW-44802', DATE '2022-11-03', 'VERIFIED', CURRENT_TIMESTAMP),
            (4, 1, 'PADI-OW-99304', DATE '2024-02-18', 'VERIFIED', CURRENT_TIMESTAMP);