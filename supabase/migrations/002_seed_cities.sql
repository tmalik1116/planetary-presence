BEGIN;

INSERT INTO cities (name, country, state, coordinates) VALUES
  -- North America (USA)
  ('New York City',    'United States', 'New York',     ST_GeogFromText('POINT(-74.0060 40.7128)')),
  ('Los Angeles',      'United States', 'California',   ST_GeogFromText('POINT(-118.2437 34.0522)')),
  ('Chicago',          'United States', 'Illinois',     ST_GeogFromText('POINT(-87.6298 41.8781)')),
  ('Miami',            'United States', 'Florida',      ST_GeogFromText('POINT(-80.1918 25.7617)')),
  ('Las Vegas',        'United States', 'Nevada',       ST_GeogFromText('POINT(-115.1398 36.1699)')),
  ('San Francisco',    'United States', 'California',   ST_GeogFromText('POINT(-122.4194 37.7749)')),
  ('New Orleans',      'United States', 'Louisiana',    ST_GeogFromText('POINT(-90.0715 29.9511)')),
  ('Honolulu',         'United States', 'Hawaii',       ST_GeogFromText('POINT(-157.8583 21.3069)')),

  -- North America (Canada)
  ('Toronto',          'Canada',        'Ontario',      ST_GeogFromText('POINT(-79.3832 43.6532)')),
  ('Vancouver',        'Canada',        'British Columbia', ST_GeogFromText('POINT(-123.1216 49.2827)')),

  -- North America (Mexico & Caribbean)
  ('Mexico City',      'Mexico',        NULL,           ST_GeogFromText('POINT(-99.1332 19.4326)')),
  ('Cancún',           'Mexico',        NULL,           ST_GeogFromText('POINT(-86.8515 21.1619)')),

  -- South America
  ('Rio de Janeiro',   'Brazil',        NULL,           ST_GeogFromText('POINT(-43.1729 -22.9068)')),
  ('São Paulo',        'Brazil',        NULL,           ST_GeogFromText('POINT(-46.6333 -23.5505)')),
  ('Buenos Aires',     'Argentina',     NULL,           ST_GeogFromText('POINT(-58.3816 -34.6037)')),
  ('Lima',             'Peru',          NULL,           ST_GeogFromText('POINT(-77.0428 -12.0464)')),
  ('Bogotá',           'Colombia',      NULL,           ST_GeogFromText('POINT(-74.0721 4.7110)')),

  -- Europe (Western)
  ('London',           'United Kingdom', NULL,          ST_GeogFromText('POINT(-0.1276 51.5074)')),
  ('Paris',            'France',        NULL,           ST_GeogFromText('POINT(2.3522 48.8566)')),
  ('Amsterdam',        'Netherlands',   NULL,           ST_GeogFromText('POINT(4.9041 52.3676)')),
  ('Barcelona',        'Spain',         NULL,           ST_GeogFromText('POINT(2.1734 41.3851)')),
  ('Madrid',           'Spain',         NULL,           ST_GeogFromText('POINT(-3.7038 40.4168)')),
  ('Lisbon',           'Portugal',      NULL,           ST_GeogFromText('POINT(-9.1393 38.7223)')),
  ('Rome',             'Italy',         NULL,           ST_GeogFromText('POINT(12.4964 41.9028)')),
  ('Venice',           'Italy',         NULL,           ST_GeogFromText('POINT(12.3155 45.4408)')),
  ('Berlin',           'Germany',       NULL,           ST_GeogFromText('POINT(13.4050 52.5200)')),

  -- Europe (Northern & Eastern)
  ('Stockholm',        'Sweden',        NULL,           ST_GeogFromText('POINT(18.0686 59.3293)')),
  ('Copenhagen',       'Denmark',       NULL,           ST_GeogFromText('POINT(12.5683 55.6761)')),
  ('Prague',           'Czech Republic', NULL,          ST_GeogFromText('POINT(14.4378 50.0755)')),
  ('Vienna',           'Austria',       NULL,           ST_GeogFromText('POINT(16.3738 48.2082)')),
  ('Athens',           'Greece',        NULL,           ST_GeogFromText('POINT(23.7275 37.9838)')),
  ('Istanbul',         'Turkey',        NULL,           ST_GeogFromText('POINT(28.9784 41.0082)')),

  -- Africa
  ('Cairo',            'Egypt',         NULL,           ST_GeogFromText('POINT(31.2357 30.0444)')),
  ('Cape Town',        'South Africa',  NULL,           ST_GeogFromText('POINT(18.4241 -33.9249)')),
  ('Marrakech',        'Morocco',       NULL,           ST_GeogFromText('POINT(-7.9811 31.6295)')),
  ('Nairobi',          'Kenya',         NULL,           ST_GeogFromText('POINT(36.8219 -1.2921)')),

  -- Middle East
  ('Dubai',            'United Arab Emirates', NULL,    ST_GeogFromText('POINT(55.2708 25.2048)')),
  ('Jerusalem',        'Israel',        NULL,           ST_GeogFromText('POINT(35.2137 31.7683)')),

  -- South Asia
  ('Mumbai',           'India',         NULL,           ST_GeogFromText('POINT(72.8777 19.0760)')),
  ('Delhi',            'India',         NULL,           ST_GeogFromText('POINT(77.1025 28.7041)')),

  -- East & Southeast Asia
  ('Tokyo',            'Japan',         NULL,           ST_GeogFromText('POINT(139.6917 35.6895)')),
  ('Kyoto',            'Japan',         NULL,           ST_GeogFromText('POINT(135.7681 35.0116)')),
  ('Beijing',          'China',         NULL,           ST_GeogFromText('POINT(116.4074 39.9042)')),
  ('Shanghai',         'China',         NULL,           ST_GeogFromText('POINT(121.4737 31.2304)')),
  ('Hong Kong',        'China',         NULL,           ST_GeogFromText('POINT(114.1694 22.3193)')),
  ('Singapore',        'Singapore',     NULL,           ST_GeogFromText('POINT(103.8198 1.3521)')),
  ('Bangkok',          'Thailand',      NULL,           ST_GeogFromText('POINT(100.5018 13.7563)')),
  ('Bali',             'Indonesia',     NULL,           ST_GeogFromText('POINT(115.1889 -8.4095)')),

  -- Oceania
  ('Sydney',           'Australia',     'New South Wales', ST_GeogFromText('POINT(151.2093 -33.8688)')),
  ('Melbourne',        'Australia',     'Victoria',     ST_GeogFromText('POINT(144.9631 -37.8136)'));

COMMIT;
