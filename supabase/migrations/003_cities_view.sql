CREATE OR REPLACE VIEW cities_view AS
SELECT
  id,
  name,
  country,
  state,
  ST_Y(coordinates::geometry) AS lat,
  ST_X(coordinates::geometry) AS lng
FROM cities;
