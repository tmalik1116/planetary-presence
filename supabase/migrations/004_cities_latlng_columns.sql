ALTER TABLE cities ADD COLUMN IF NOT EXISTS lat DOUBLE PRECISION;
ALTER TABLE cities ADD COLUMN IF NOT EXISTS lng DOUBLE PRECISION;

UPDATE cities
SET
  lat = ST_Y(coordinates::geometry),
  lng = ST_X(coordinates::geometry)
WHERE coordinates IS NOT NULL;
