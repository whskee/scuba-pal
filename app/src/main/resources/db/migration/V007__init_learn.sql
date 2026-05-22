CREATE TABLE learn.articles (
    learn_article_id  BIGSERIAL PRIMARY KEY,
    slug              VARCHAR(140) NOT NULL UNIQUE,
    title             VARCHAR(180) NOT NULL,
    summary           VARCHAR(600) NOT NULL,
    content           TEXT NOT NULL,
    category          VARCHAR(80) NOT NULL,
    difficulty_level  VARCHAR(40) NOT NULL,
    estimated_minutes INTEGER NOT NULL DEFAULT 5,
    display_order     INTEGER NOT NULL DEFAULT 0,
    is_published      BOOLEAN NOT NULL DEFAULT true,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_learn_articles_published_order
ON learn.articles (
    is_published,
    display_order,
    title
);

INSERT INTO learn.articles ( slug, title, summary, content, category, difficulty_level, estimated_minutes, display_order )
     VALUES ( 'pre-dive-buddy-check', 'Pre-dive buddy check', 'Run a consistent BWRAF check before every entry so small equipment issues stay on the boat or shore.', 'Before entering the water, confirm BCD inflation and dump valves, weights and releases, air pressure and alternate second stage function, final releases and hoses, and a shared plan for entry, descent, turn pressure, and ascent. Speak each step out loud with your buddy.', 'Safety', 'Beginner', 6, 10 ),
            ( 'equalization-basics', 'Equalization basics', 'Protect your ears by equalizing early, often, and before discomfort starts.', 'Equalize on the surface before descent, then every few feet while descending. If one ear does not clear, stop, ascend slightly, and try again gently. Never force equalization through pain; call the dive if pressure does not resolve.', 'Skills', 'Beginner', 5, 20 ),
            ( 'buoyancy-trim-control', 'Buoyancy and trim control', 'Use breathing, weighting, and small BCD adjustments to stay relaxed and horizontal.', 'Start with a proper weight check, add air in short bursts during descent, and use slow breathing to fine tune depth. Keep hoses streamlined, avoid bicycle kicking, and pause often to feel whether your body is balanced in the water.', 'Skills', 'Intermediate', 8, 30 ),
            ( 'no-decompression-awareness', 'No-decompression awareness', 'Track depth, time, ascent rate, and safety stops throughout the dive instead of only at the end.', 'Plan your maximum depth and turn point before entering. Monitor your computer regularly, ascend slowly, hold a safety stop when conditions allow, and build extra conservatism when cold, tired, deep, or diving multiple days.', 'Planning', 'Intermediate', 7, 40 ),
            ( 'marine-life-etiquette', 'Marine life etiquette', 'Better encounters happen when divers move slowly, keep distance, and never touch the reef.', 'Stay neutrally buoyant, secure dangling gear, approach animals from the side without chasing, and keep fins away from coral and sand. Take only photos and leave the site cleaner than you found it.', 'Environment', 'Beginner', 4, 50 ) ON conflict ( slug ) DO NOTHING;