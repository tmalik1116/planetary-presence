-- PostGIS extension for coordinates + 10km radius queries
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE cities (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  country     TEXT NOT NULL,
  state       TEXT,
  coordinates GEOGRAPHY(POINT, 4326)
);

CREATE TABLE users (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username     TEXT UNIQUE NOT NULL,
  email        TEXT UNIQUE NOT NULL,
  avatar_url   TEXT,
  home_city_id UUID REFERENCES cities(id),
  total_points INT NOT NULL DEFAULT 0,
  coordinates  GEOGRAPHY(POINT, 4326),
  joined_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE follows (
  follower_id  UUID NOT NULL REFERENCES users(id),
  following_id UUID NOT NULL REFERENCES users(id),
  followed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id != following_id)
);

CREATE TABLE quests (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title                 TEXT NOT NULL,
  description           TEXT,
  category              TEXT NOT NULL CHECK (category IN ('nature','culture','food','landmark')),
  city_id               UUID NOT NULL REFERENCES cities(id),
  status                TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','active')),
  created_by            UUID NOT NULL REFERENCES users(id),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  current_points        INT NOT NULL DEFAULT 10,
  completion_count      INT NOT NULL DEFAULT 0,
  avg_difficulty_rating NUMERIC(3,2) NOT NULL DEFAULT 0,
  rating_count          INT NOT NULL DEFAULT 0,
  net_votes             INT NOT NULL DEFAULT 0
);

CREATE TABLE quest_votes (
  quest_id UUID NOT NULL REFERENCES quests(id),
  user_id  UUID NOT NULL REFERENCES users(id),
  vote     TEXT NOT NULL CHECK (vote IN ('up','down')),
  voted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (quest_id, user_id)
);

CREATE TABLE completions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quest_id          UUID NOT NULL REFERENCES quests(id),
  user_id           UUID NOT NULL REFERENCES users(id),
  city_id           UUID NOT NULL REFERENCES cities(id),
  points_awarded    INT NOT NULL,
  is_repeat         BOOLEAN NOT NULL DEFAULT FALSE,
  media_url         TEXT NOT NULL,
  media_type        TEXT NOT NULL CHECK (media_type IN ('photo','video')),
  tagline           TEXT,
  difficulty_rating INT NOT NULL CHECK (difficulty_rating BETWEEN 1 AND 5),
  completed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE completion_tags (
  completion_id  UUID NOT NULL REFERENCES completions(id),
  tagged_user_id UUID NOT NULL REFERENCES users(id),
  PRIMARY KEY (completion_id, tagged_user_id)
);

CREATE TABLE user_city_stats (
  user_id     UUID NOT NULL REFERENCES users(id),
  city_id     UUID NOT NULL REFERENCES cities(id),
  country     TEXT NOT NULL,
  points      INT NOT NULL DEFAULT 0,
  quest_count INT NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, city_id)
);
