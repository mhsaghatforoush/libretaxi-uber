-- Add PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Drop existing objects (if needed)
-- DROP INDEX IF EXISTS idx_user_id_at_dismissed_feature_callouts;
-- DROP INDEX IF EXISTS idx_created_at_utc_posts;
-- DROP INDEX IF EXISTS idx_user_id_and_created_at_utc;
-- DROP TABLE IF EXISTS dismissed_feature_callouts;
-- DROP INDEX IF EXISTS users_geog_idx;
-- DROP TABLE IF EXISTS posts;
-- DROP TABLE IF EXISTS users;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    "userId" BIGINT NOT NULL,
    "menuId" INT,
    "username" TEXT,
    "firstName" TEXT,
    "lastName" TEXT,
    "lon" DOUBLE PRECISION,
    "lat" DOUBLE PRECISION,
    "geog" GEOGRAPHY(POINT, 4326),
    "languageCode" TEXT,
    "reportCnt" INT DEFAULT 0,
    "shadowBanned" BOOLEAN DEFAULT FALSE,
    "createdAtUtc" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    PRIMARY KEY ("userId")
);

-- Create spatial index on users table
CREATE INDEX IF NOT EXISTS users_geog_idx ON users USING GIST(geog);

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    "postId" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "userId" BIGINT NOT NULL REFERENCES users("userId"),
    "text" TEXT,
    "lon" DOUBLE PRECISION,
    "lat" DOUBLE PRECISION,
    "geog" GEOGRAPHY(POINT, 4326),
    "reportCnt" INT DEFAULT 0,
    "createdAtUtc" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);

-- Create indices on posts table
CREATE INDEX IF NOT EXISTS idx_created_at_utc_posts ON posts("createdAtUtc");
CREATE INDEX IF NOT EXISTS idx_user_id_and_created_at_utc ON posts("userId", "createdAtUtc");

-- Create dismissed_feature_callouts table
CREATE TABLE IF NOT EXISTS dismissed_feature_callouts (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "userId" BIGINT NOT NULL, -- Do not reference users table to allow usage when user isn't present
    "featureName" TEXT NOT NULL,
    "createdAtUtc" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    UNIQUE ("userId", "featureName")
);

-- Create index on dismissed_feature_callouts table
CREATE INDEX IF NOT EXISTS idx_user_id_at_dismissed_feature_callouts ON dismissed_feature_callouts("userId");

-- Create or recreate libretaxi role
DROP ROLE IF EXISTS libretaxi;
CREATE ROLE libretaxi WITH LOGIN PASSWORD 'libretaxi';
