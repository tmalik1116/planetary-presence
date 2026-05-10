BEGIN;

-- Seed user placeholder (required by foreign key on quests.created_by)
INSERT INTO users (id, username, email)
VALUES ('00000000-0000-0000-0000-000000000001', 'seed_user', 'seed@planetarypresence.app')
ON CONFLICT (id) DO NOTHING;

-- ─────────────────────────────────────────────
-- TOKYO
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Sunrise at Mount Takao',
  'Wake before dawn and hike to the summit of Mount Takao to watch the sun rise over the Kanto plain.',
  'nature', (SELECT id FROM cities WHERE name = 'Tokyo'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the hidden Yanaka alley shrine',
  'Navigate the backstreets of Yanaka to find a small neighbourhood shrine tucked between wooden machiya houses.',
  'culture', (SELECT id FROM cities WHERE name = 'Tokyo'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Eat ramen at a 50-year-old stall',
  'Track down one of Tokyo''s legendary old-school ramen counters that has been serving the same broth for generations.',
  'food', (SELECT id FROM cities WHERE name = 'Tokyo'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Photograph Tokyo Tower at midnight',
  'Capture the illuminated Tokyo Tower against a clear night sky from the base observation deck.',
  'landmark', (SELECT id FROM cities WHERE name = 'Tokyo'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Attend a sumo morning practice',
  'Arrive at a sumo stable by 6 am and watch wrestlers train — an experience most tourists never find.',
  'culture', (SELECT id FROM cities WHERE name = 'Tokyo'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Discover the secret Shibuya rooftop garden',
  'Find the rooftop green space hidden above a Shibuya department store and enjoy the skyline without the crowds.',
  'nature', (SELECT id FROM cities WHERE name = 'Tokyo'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 22
);

-- ─────────────────────────────────────────────
-- KYOTO
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Walk the Philosopher''s Path at cherry blossom',
  'Stroll the full length of the canal-side Philosopher''s Path while sakura petals drift onto the water.',
  'nature', (SELECT id FROM cities WHERE name = 'Kyoto'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Visit the oldest temple in Kyoto',
  'Find Kōryū-ji, founded in 603 AD, and locate the National Treasure hall containing Japan''s oldest wooden sculpture.',
  'culture', (SELECT id FROM cities WHERE name = 'Kyoto'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch a maiko performance in Gion',
  'Attend a traditional ozashiki banquet or public stage show featuring a trainee geisha.',
  'culture', (SELECT id FROM cities WHERE name = 'Kyoto'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Try kaiseki at a century-old ryotei',
  'Book a seat at a traditional multi-course kaiseki restaurant that has operated for over 100 years.',
  'food', (SELECT id FROM cities WHERE name = 'Kyoto'), 'epic', 'active',
  '00000000-0000-0000-0000-000000000001', 500, 0
),
(
  'Touch the stone lanterns of Fushimi Inari at dusk',
  'Hike past the thousands of torii gates up to the summit shrine as the lanterns glow at twilight.',
  'landmark', (SELECT id FROM cities WHERE name = 'Kyoto'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 31
);

-- ─────────────────────────────────────────────
-- PARIS
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Find the street art mural in Belleville',
  'Explore the Belleville neighbourhood and photograph its most striking outdoor mural.',
  'culture', (SELECT id FROM cities WHERE name = 'Paris'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Eat at a brasserie open since the 1900s',
  'Dine at one of the grand Parisian brasseries that has been serving classics like steak-frites since before WWI.',
  'food', (SELECT id FROM cities WHERE name = 'Paris'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Photograph the Eiffel Tower light show',
  'Position yourself at Trocadéro at exactly 10 pm and capture the full sparkling light show.',
  'landmark', (SELECT id FROM cities WHERE name = 'Paris'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Picnic beside the Canal Saint-Martin',
  'Buy provisions from a local épicerie and enjoy a meal on the iron footbridge over the canal.',
  'nature', (SELECT id FROM cities WHERE name = 'Paris'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Descend into the Catacombs after hours',
  'Join a guided evening tour of the Paris Catacombs and walk among six million Parisians who came before.',
  'landmark', (SELECT id FROM cities WHERE name = 'Paris'), 'hard', 'pending',
  '00000000-0000-0000-0000-000000000001', 200, 18
);

-- ─────────────────────────────────────────────
-- LONDON
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Touch the historic city gate at Temple Bar',
  'Find the old boundary marker of the City of London at Temple Bar and photograph the dragon statue.',
  'landmark', (SELECT id FROM cities WHERE name = 'London'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the best hidden café in Shoreditch',
  'Navigate the backstreets of Shoreditch to find a specialty coffee shop that doesn''t advertise online.',
  'food', (SELECT id FROM cities WHERE name = 'London'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch the Changing of the Guard from inside the crowd',
  'Arrive an hour early and secure a front-row position at Buckingham Palace for the full ceremony.',
  'culture', (SELECT id FROM cities WHERE name = 'London'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Walk the ancient Roman city wall',
  'Follow the remnants of the original Roman wall from the Barbican to Tower Hill.',
  'culture', (SELECT id FROM cities WHERE name = 'London'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Photograph Tower Bridge from below at sunrise',
  'Stand directly beneath Tower Bridge at dawn and capture the Gothic towers against the morning sky.',
  'landmark', (SELECT id FROM cities WHERE name = 'London'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 27
);

-- ─────────────────────────────────────────────
-- NEW YORK CITY
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Walk the entire High Line at golden hour',
  'Start at Gansevoort Street and walk north along the elevated park as the sun sets over the Hudson.',
  'nature', (SELECT id FROM cities WHERE name = 'New York City'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Try the local street food market at Smorgasburg',
  'Visit Brooklyn''s famous open-air food market and sample dishes from at least five different vendors.',
  'food', (SELECT id FROM cities WHERE name = 'New York City'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the underground market below Grand Central',
  'Locate the Dining Concourse hidden beneath Grand Central Terminal and eat at one of its long-running counters.',
  'landmark', (SELECT id FROM cities WHERE name = 'New York City'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'See a free jazz set in Harlem',
  'Find a Harlem venue offering live jazz on a weeknight without a cover charge.',
  'culture', (SELECT id FROM cities WHERE name = 'New York City'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Ride the Staten Island Ferry at dusk',
  'Take the free ferry at sunset for an unobstructed view of the Manhattan skyline and the Statue of Liberty.',
  'landmark', (SELECT id FROM cities WHERE name = 'New York City'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 14
);

-- ─────────────────────────────────────────────
-- BARCELONA
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Watch a traditional castellers performance',
  'Find a local neighbourhood festival where castellers build their human towers and witness the top person climb.',
  'culture', (SELECT id FROM cities WHERE name = 'Barcelona'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Eat tapas at a bar open since the Civil War era',
  'Find one of Barcelona''s oldest tapas bars that pre-dates 1940 and order the house specialty.',
  'food', (SELECT id FROM cities WHERE name = 'Barcelona'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Photograph the Sagrada Família at sunrise',
  'Arrive before the tourist crowds and capture the east-facing Nativity facade lit by the morning sun.',
  'landmark', (SELECT id FROM cities WHERE name = 'Barcelona'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Walk the ancient forest of Collserola',
  'Hike the Carretera de les Aigües trail through the Collserola natural park above the city.',
  'nature', (SELECT id FROM cities WHERE name = 'Barcelona'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 9
);

-- ─────────────────────────────────────────────
-- ROME
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Find the oldest church in Rome',
  'Locate Santa Pudenziana, dating to the 4th century, and find its famous apse mosaic inside.',
  'culture', (SELECT id FROM cities WHERE name = 'Rome'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat supplì from a 100-year-old Roman friggitoria',
  'Find a traditional Roman fry shop that has been making supplì al telefono for generations.',
  'food', (SELECT id FROM cities WHERE name = 'Rome'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Touch the historic city gate of Porta Maggiore',
  'Photograph the ancient aqueduct arch and city gate of Porta Maggiore from its base.',
  'landmark', (SELECT id FROM cities WHERE name = 'Rome'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Walk the Appian Way at dawn',
  'Begin at the Porta San Sebastiano and walk the ancient road lined with tombs as the city wakes up.',
  'nature', (SELECT id FROM cities WHERE name = 'Rome'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch the sun set over the Forum from the Palatine Hill',
  'Climb to the top of the Palatine Hill and photograph the Roman Forum bathed in golden light.',
  'landmark', (SELECT id FROM cities WHERE name = 'Rome'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 33
);

-- ─────────────────────────────────────────────
-- ISTANBUL
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Find the underground market of the Grand Bazaar',
  'Navigate to the oldest section of the Grand Bazaar and find the jewellers'' quarter hidden inside.',
  'landmark', (SELECT id FROM cities WHERE name = 'Istanbul'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Try simit from a 150-year-old bakery',
  'Find one of Istanbul''s original simit bakeries and eat a fresh ring still warm from the oven.',
  'food', (SELECT id FROM cities WHERE name = 'Istanbul'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Watch a whirling dervish ceremony',
  'Attend an authentic Sema ceremony performed by the Mevlevi Order — not a tourist show.',
  'culture', (SELECT id FROM cities WHERE name = 'Istanbul'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Photograph the Bosphorus bridge at sunset',
  'Position yourself at Ortaköy Mosque with the suspension bridge glowing behind it at dusk.',
  'landmark', (SELECT id FROM cities WHERE name = 'Istanbul'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 20
);

-- ─────────────────────────────────────────────
-- BANGKOK
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Try the local street food market at Or Tor Kor',
  'Visit Bangkok''s premium fresh market and sample regional Thai dishes from vendors across the country.',
  'food', (SELECT id FROM cities WHERE name = 'Bangkok'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Visit the oldest temple in Bangkok',
  'Find Wat Pho, one of the oldest temple complexes in the city, and locate the reclining Buddha.',
  'culture', (SELECT id FROM cities WHERE name = 'Bangkok'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Sunrise at the roof of Wat Saket',
  'Climb the Golden Mount before 7 am and watch the city emerge from the morning haze.',
  'nature', (SELECT id FROM cities WHERE name = 'Bangkok'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Navigate the klongs by longtail boat',
  'Board a local longtail boat in the Thonburi canals and reach a neighbourhood untouched by tourism.',
  'landmark', (SELECT id FROM cities WHERE name = 'Bangkok'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 16
);

-- ─────────────────────────────────────────────
-- SINGAPORE
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Walk the ancient forest trail of Bukit Timah',
  'Hike the summit trail of Bukit Timah Nature Reserve — Singapore''s highest natural point.',
  'nature', (SELECT id FROM cities WHERE name = 'Singapore'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat at a hawker centre that has been open for 40 years',
  'Find one of the original hawker centres and locate a stall that has operated since the 1980s.',
  'food', (SELECT id FROM cities WHERE name = 'Singapore'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the street art along Haji Lane',
  'Walk the full length of Haji Lane and photograph the most intricate mural on a shophouse wall.',
  'culture', (SELECT id FROM cities WHERE name = 'Singapore'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Photograph Gardens by the Bay supertrees at night',
  'Capture the illuminated supertree grove during the Garden Rhapsody light and sound show.',
  'landmark', (SELECT id FROM cities WHERE name = 'Singapore'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 11
);

-- ─────────────────────────────────────────────
-- SYDNEY
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Sunrise at the summit of the Spit Bridge headland',
  'Hike the Manly to Spit Bridge coastal walk starting at first light and watch the harbour wake up.',
  'nature', (SELECT id FROM cities WHERE name = 'Sydney'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat a meat pie from a 100-year-old bakery',
  'Track down one of Sydney''s oldest bakeries still making the classic Australian meat pie from scratch.',
  'food', (SELECT id FROM cities WHERE name = 'Sydney'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Photograph the Opera House from the water',
  'Rent a kayak or join a harbour ferry and photograph the Opera House from the level of the water.',
  'landmark', (SELECT id FROM cities WHERE name = 'Sydney'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the hidden Aboriginal rock engravings',
  'Locate one of the sandstone Aboriginal engraving sites concealed in the Royal National Park just south of the city.',
  'culture', (SELECT id FROM cities WHERE name = 'Sydney'), 'hard', 'pending',
  '00000000-0000-0000-0000-000000000001', 200, 28
);

-- ─────────────────────────────────────────────
-- DUBAI
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Watch the Dubai Fountain show from a dhow',
  'Book a traditional wooden dhow cruise on Dubai Creek timed to pass the Fountain during its evening performance.',
  'landmark', (SELECT id FROM cities WHERE name = 'Dubai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the hidden gold souk alley',
  'Explore the back alleys of the Gold Souk in Deira and find the small traders behind the main shopfronts.',
  'landmark', (SELECT id FROM cities WHERE name = 'Dubai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat at a Pakistani truckers'' café in Al Quoz',
  'Find one of the no-frills South Asian canteens in the industrial Al Quoz district and eat with the workers.',
  'food', (SELECT id FROM cities WHERE name = 'Dubai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Walk the ancient Al Fahidi wind-tower village',
  'Explore the Al Fahidi Historical Neighbourhood and photograph the original wind-tower architecture.',
  'culture', (SELECT id FROM cities WHERE name = 'Dubai'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 7
);

-- ─────────────────────────────────────────────
-- MUMBAI
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Eat a full thali at a 100-year-old Irani café',
  'Find one of Mumbai''s surviving Irani cafés — some open since the 1920s — and order the full set meal.',
  'food', (SELECT id FROM cities WHERE name = 'Mumbai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch a traditional Lavani performance',
  'Attend a Lavani folk dance show in the city — the traditional Maharashtrian performance art form.',
  'culture', (SELECT id FROM cities WHERE name = 'Mumbai'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Photograph the Gateway of India at sunrise',
  'Arrive at the Gateway of India before 6 am and capture it without tourist crowds.',
  'landmark', (SELECT id FROM cities WHERE name = 'Mumbai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the hidden waterfall inside Sanjay Gandhi Park',
  'Hike deep into the Sanjay Gandhi National Park to find the waterfall that most city residents have never seen.',
  'nature', (SELECT id FROM cities WHERE name = 'Mumbai'), 'hard', 'pending',
  '00000000-0000-0000-0000-000000000001', 200, 24
);

-- ─────────────────────────────────────────────
-- CAIRO
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Watch the sun rise over the Giza plateau',
  'Arrive at the Giza plateau before dawn and photograph the pyramids lit by the first rays of light.',
  'landmark', (SELECT id FROM cities WHERE name = 'Cairo'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Find the oldest café in Islamic Cairo',
  'Locate El Fishawy café in Khan el-Khalili — open continuously since 1773 — and drink a glass of tea.',
  'food', (SELECT id FROM cities WHERE name = 'Cairo'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Visit the oldest mosque in Africa',
  'Find the Mosque of Amr ibn al-As, built in 642 AD and considered the oldest mosque on the African continent.',
  'culture', (SELECT id FROM cities WHERE name = 'Cairo'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Walk the ancient forest trail of Wadi Degla',
  'Hike through the Wadi Degla Protectorate canyon just outside Cairo, a desert wilderness inside the city limits.',
  'nature', (SELECT id FROM cities WHERE name = 'Cairo'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 13
);

-- ─────────────────────────────────────────────
-- NAIROBI
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Spot a giraffe from within city limits',
  'Visit the Nairobi Giraffe Centre or the viewpoint at Karen Blixen Museum to see Rothschild giraffes with the skyline behind them.',
  'nature', (SELECT id FROM cities WHERE name = 'Nairobi'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Eat nyama choma at a local roadside butchery',
  'Skip the hotel and find a neighbourhood butchery where locals order roasted goat by the kilo.',
  'food', (SELECT id FROM cities WHERE name = 'Nairobi'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the Uhuru Park open-air art market',
  'Navigate to the weekend crafts and paintings market inside Uhuru Park and speak to a working artist.',
  'culture', (SELECT id FROM cities WHERE name = 'Nairobi'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Photograph lions in Nairobi National Park at sunrise',
  'Join a dawn game drive in Nairobi National Park — the only wildlife park in the world inside a capital city.',
  'landmark', (SELECT id FROM cities WHERE name = 'Nairobi'), 'epic', 'pending',
  '00000000-0000-0000-0000-000000000001', 500, 42
);

-- ─────────────────────────────────────────────
-- MEXICO CITY
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Visit the oldest building in the Americas',
  'Find the Pyramid of Cuicuilco on the southern edge of the city — estimated to be over 2,500 years old.',
  'culture', (SELECT id FROM cities WHERE name = 'Mexico City'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat tacos at a market open since 1957',
  'Find the Mercado de Medellín or another vintage Mexico City market and eat at a taco stall that has been there for decades.',
  'food', (SELECT id FROM cities WHERE name = 'Mexico City'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Walk the Bosque de Chapultepec at dawn',
  'Enter the vast Chapultepec forest before 7 am and walk to the second section — rarely visited by tourists.',
  'nature', (SELECT id FROM cities WHERE name = 'Mexico City'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the mural by Diego Rivera in the Palace',
  'Enter the National Palace and stand in front of Rivera''s epic mural depicting the history of Mexico.',
  'landmark', (SELECT id FROM cities WHERE name = 'Mexico City'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 19
);

-- ─────────────────────────────────────────────
-- RIO DE JANEIRO
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Sunrise at the summit of Pedra Bonita',
  'Hike the Tijuca Forest trail to Pedra Bonita before dawn and watch the city light up below you.',
  'nature', (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Eat acarajé from a Bahiana street vendor',
  'Find an authentic Bahiana woman vendor selling acarajé — the traditional black-eyed pea fritter — in the open air.',
  'food', (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Watch a samba rehearsal in Lapa',
  'Enter a samba school in the Lapa neighbourhood on a rehearsal night and join the practice session.',
  'culture', (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Photograph Christ the Redeemer at sunrise',
  'Take the first cog train up Corcovado and photograph the statue before the haze builds.',
  'landmark', (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 35
);

-- ─────────────────────────────────────────────
-- BUENOS AIRES
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Watch a tango performance at La Catedral',
  'Find the infamous milonga venue La Catedral hidden inside a converted warehouse in Almagro.',
  'culture', (SELECT id FROM cities WHERE name = 'Buenos Aires'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat an asado with locals in the suburbs',
  'Accept or arrange an invitation to a traditional Sunday asado barbecue — not at a tourist parrilla.',
  'food', (SELECT id FROM cities WHERE name = 'Buenos Aires'), 'epic', 'active',
  '00000000-0000-0000-0000-000000000001', 500, 0
),
(
  'Find the street art murals of Palermo',
  'Walk the grid streets of Palermo Soho and photograph all the large-scale murals commissioned by the city.',
  'culture', (SELECT id FROM cities WHERE name = 'Buenos Aires'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Walk through the Ecological Reserve at low tide',
  'Enter the Reserva Ecológica Costanera Sur at low tide when the mud flats expose bird life.',
  'nature', (SELECT id FROM cities WHERE name = 'Buenos Aires'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 10
);

-- ─────────────────────────────────────────────
-- AMSTERDAM
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Cycle the full canal ring road at dawn',
  'Rent a city bike before 6 am and complete the full loop of the UNESCO canal ring before traffic builds.',
  'nature', (SELECT id FROM cities WHERE name = 'Amsterdam'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the smallest house in Amsterdam',
  'Locate the narrowest historic house on the Singel canal and photograph it next to a wider building for scale.',
  'landmark', (SELECT id FROM cities WHERE name = 'Amsterdam'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Eat herring at an outdoor haringhandel stall',
  'Find a traditional outdoor herring cart and eat a whole raw herring the Dutch way — head tilted back.',
  'food', (SELECT id FROM cities WHERE name = 'Amsterdam'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Visit a clandestine church (schuilkerk)',
  'Find Ons'' Lieve Heer op Solder — a complete 17th-century Catholic church hidden in the attic of a canal house.',
  'culture', (SELECT id FROM cities WHERE name = 'Amsterdam'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 23
);

-- ─────────────────────────────────────────────
-- BERLIN
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Find a remaining stretch of the Berlin Wall',
  'Locate one of the surviving sections of the Wall — not the East Side Gallery — in a residential neighbourhood.',
  'landmark', (SELECT id FROM cities WHERE name = 'Berlin'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat currywurst at a kiosk open since 1960',
  'Find one of the original Currywurst imbiss stands in the city that has been serving the dish for decades.',
  'food', (SELECT id FROM cities WHERE name = 'Berlin'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the street art mural in Kreuzberg',
  'Walk the SO36 quarter of Kreuzberg and photograph the most striking political mural on a building facade.',
  'culture', (SELECT id FROM cities WHERE name = 'Berlin'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Walk the ancient forest of Grunewald at dusk',
  'Enter the Grunewald forest by the Havel lake at sunset and walk to the Teufelsberg hill for the view.',
  'nature', (SELECT id FROM cities WHERE name = 'Berlin'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 17
);

-- ─────────────────────────────────────────────
-- PRAGUE
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Touch the historic city gate of the Powder Tower',
  'Stand at the base of the Powder Tower — the original 15th-century gate of the Old Town — and photograph it from below.',
  'landmark', (SELECT id FROM cities WHERE name = 'Prague'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the best hidden café in Malá Strana',
  'Wander the cobblestone streets of Malá Strana and find a coffee house not listed on any travel site.',
  'food', (SELECT id FROM cities WHERE name = 'Prague'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch the Astronomical Clock strike at midnight',
  'Stay awake and position yourself in the Old Town Square to watch the Orloj perform its midnight show.',
  'culture', (SELECT id FROM cities WHERE name = 'Prague'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Sunrise at the summit of Petřín Hill',
  'Climb Petřín Hill before dawn and watch the spires of the city emerge from the morning mist.',
  'nature', (SELECT id FROM cities WHERE name = 'Prague'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 8
);

-- ─────────────────────────────────────────────
-- VIENNA
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Eat Sachertorte at the original Café Sacher',
  'Sit in the original Hotel Sacher café and order the cake as it has been served since 1832.',
  'food', (SELECT id FROM cities WHERE name = 'Vienna'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Watch a performance at the Vienna State Opera',
  'Attend a full performance at the Staatsoper — not a concert or matinée, but an evening opera production.',
  'culture', (SELECT id FROM cities WHERE name = 'Vienna'), 'epic', 'active',
  '00000000-0000-0000-0000-000000000001', 500, 0
),
(
  'Photograph the Schönbrunn Palace at sunrise',
  'Walk up to the Gloriette viewpoint on the hill above Schönbrunn Palace before 7 am.',
  'landmark', (SELECT id FROM cities WHERE name = 'Vienna'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Walk the Vienna Woods trail to the Kahlenberg',
  'Hike from Grinzing village up through the Wienerwald to the Kahlenberg viewpoint above the city.',
  'nature', (SELECT id FROM cities WHERE name = 'Vienna'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 29
);

-- ─────────────────────────────────────────────
-- ATHENS
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Watch the sun rise over the Acropolis',
  'Climb Filopappou Hill before dawn and watch the Parthenon catch the first rays of sunrise.',
  'landmark', (SELECT id FROM cities WHERE name = 'Athens'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the oldest taverna in Athens',
  'Locate one of the original 19th-century tavernas in the Monastiraki or Psiri district and eat a traditional meal.',
  'food', (SELECT id FROM cities WHERE name = 'Athens'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Walk the ancient forest trail of Hymettus',
  'Hike the pine-covered trails of Mount Hymettus on the eastern edge of the city.',
  'nature', (SELECT id FROM cities WHERE name = 'Athens'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Attend a rebetiko music session',
  'Find a live rebetiko performance in a small Athens venue — the blues music of the Greek underworld.',
  'culture', (SELECT id FROM cities WHERE name = 'Athens'), 'hard', 'pending',
  '00000000-0000-0000-0000-000000000001', 200, 38
);

-- ─────────────────────────────────────────────
-- CAPE TOWN
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Hike to the summit of Table Mountain without the cable car',
  'Take the Platteklip Gorge trail from the base to the summit under your own power.',
  'nature', (SELECT id FROM cities WHERE name = 'Cape Town'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Eat a gatsby at a local shop in Athlone',
  'Travel to Athlone and order a full gatsby — the Cape Town super-sandwich — from an original takeaway.',
  'food', (SELECT id FROM cities WHERE name = 'Cape Town'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Photograph the famous bridge at sunset in Greenmarket Square',
  'Stand in Greenmarket Square at sunset and capture the Church Street facade lit by the last light.',
  'landmark', (SELECT id FROM cities WHERE name = 'Cape Town'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Watch the penguins at Boulder''s Beach at dawn',
  'Arrive at Boulder''s Beach before the park opens and watch the African penguin colony emerge from their nests.',
  'nature', (SELECT id FROM cities WHERE name = 'Cape Town'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 21
);

-- ─────────────────────────────────────────────
-- MARRAKECH
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Find the tanneries of the old medina',
  'Navigate the unmarked alleyways of the medina to the Chouara tannery and view it from a rooftop terrace.',
  'landmark', (SELECT id FROM cities WHERE name = 'Marrakech'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat a slow-cooked tagine at a 100-year-old house restaurant',
  'Find a traditional riad restaurant in the medina that has been serving home-cooked tagines for generations.',
  'food', (SELECT id FROM cities WHERE name = 'Marrakech'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch a Gnawa music ceremony',
  'Find an authentic Gnawa lila healing ritual performed in a family home or courtyard — not a tourist show.',
  'culture', (SELECT id FROM cities WHERE name = 'Marrakech'), 'epic', 'active',
  '00000000-0000-0000-0000-000000000001', 500, 0
),
(
  'Walk the ancient forest trail of the Palmeraie',
  'Walk the full perimeter path through the ancient palm grove oasis on the northern edge of Marrakech.',
  'nature', (SELECT id FROM cities WHERE name = 'Marrakech'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 6
);

-- ─────────────────────────────────────────────
-- BALI
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Sunrise at the summit of Mount Batur',
  'Begin the night hike up the active volcano at 2 am and reach the crater rim before the sun rises over the caldera.',
  'nature', (SELECT id FROM cities WHERE name = 'Bali'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Find the hidden waterfall of Nungnung',
  'Hike through rice paddies and jungle to the hidden Nungnung waterfall — 50 metres tall and rarely visited.',
  'nature', (SELECT id FROM cities WHERE name = 'Bali'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch a Kecak fire dance at Uluwatu Temple',
  'Attend the cliff-edge Kecak performance at Uluwatu at sunset as monkeys roam freely around the audience.',
  'culture', (SELECT id FROM cities WHERE name = 'Bali'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Eat a full babi guling feast from a warung',
  'Find a traditional Balinese warung serving roast suckling pig the way local families celebrate ceremonies.',
  'food', (SELECT id FROM cities WHERE name = 'Bali'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 12
);

-- ─────────────────────────────────────────────
-- HONG KONG
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Sunrise at the summit of Lantau Peak',
  'Begin the climb from Ngong Ping before 4 am and reach the 934 m summit before dawn.',
  'nature', (SELECT id FROM cities WHERE name = 'Hong Kong'), 'epic', 'active',
  '00000000-0000-0000-0000-000000000001', 500, 0
),
(
  'Eat dim sum at a teahouse open since the 1950s',
  'Find one of Hong Kong''s original cha chaan teng or dim sum houses that has operated continuously since post-war times.',
  'food', (SELECT id FROM cities WHERE name = 'Hong Kong'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Photograph the famous bridge on the tram route',
  'Ride the Peak Tram to the top and photograph the city skyline at night from Lion''s Pavilion.',
  'landmark', (SELECT id FROM cities WHERE name = 'Hong Kong'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the hidden Pak Tai temple in Wan Chai',
  'Navigate the backstreets of Wan Chai to the 1863 Pak Tai Temple, largely unknown to tourists.',
  'culture', (SELECT id FROM cities WHERE name = 'Hong Kong'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 15
);

-- ─────────────────────────────────────────────
-- SHANGHAI
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Walk the Bund at 5 am',
  'Reach the Bund promenade before sunrise and photograph the Art Deco buildings and the Pudong skyline in pre-dawn light.',
  'landmark', (SELECT id FROM cities WHERE name = 'Shanghai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat at a xiaolong bao restaurant open since 1900',
  'Find a century-old Shanghai restaurant still hand-folding soup dumplings by the original recipe.',
  'food', (SELECT id FROM cities WHERE name = 'Shanghai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the hidden longtang alleyways of the French Concession',
  'Enter a longtang alley neighbourhood from Huaihai Road and walk to a courtyard that feels entirely separate from the modern city.',
  'culture', (SELECT id FROM cities WHERE name = 'Shanghai'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Watch the sunrise from the top of the World Financial Center',
  'Book the first admission of the day to the 100th floor Sky Walk and photograph the city awakening.',
  'nature', (SELECT id FROM cities WHERE name = 'Shanghai'), 'hard', 'pending',
  '00000000-0000-0000-0000-000000000001', 200, 26
);

-- ─────────────────────────────────────────────
-- SAN FRANCISCO
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Hike the Dipsea Trail to the Pacific',
  'Run or hike the Dipsea Trail from Mill Valley over Mount Tamalpais to Stinson Beach.',
  'nature', (SELECT id FROM cities WHERE name = 'San Francisco'), 'hard', 'active',
  '00000000-0000-0000-0000-000000000001', 200, 0
),
(
  'Eat a Mission burrito at a taqueria since the 1970s',
  'Find one of the original Mission District taquerias still wrapping foil burritos the way they have for 50 years.',
  'food', (SELECT id FROM cities WHERE name = 'San Francisco'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Photograph the Golden Gate Bridge from Fort Point',
  'Stand beneath the southern tower of the Golden Gate Bridge at Fort Point and photograph it from directly below.',
  'landmark', (SELECT id FROM cities WHERE name = 'San Francisco'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Find the Clarion Alley mural project',
  'Walk the full length of Clarion Alley in the Mission and photograph all the political murals end to end.',
  'culture', (SELECT id FROM cities WHERE name = 'San Francisco'), 'easy', 'pending',
  '00000000-0000-0000-0000-000000000001', 50, 9
);

-- ─────────────────────────────────────────────
-- TORONTO
-- ─────────────────────────────────────────────
INSERT INTO quests (title, description, category, city_id, difficulty, status, created_by, current_points, net_votes) VALUES
(
  'Walk the Rouge National Urban Park trail system',
  'Hike the Rouge River trail in Canada''s only national urban park — a wilderness inside a major city.',
  'nature', (SELECT id FROM cities WHERE name = 'Toronto'), 'medium', 'active',
  '00000000-0000-0000-0000-000000000001', 100, 0
),
(
  'Eat peameal bacon at the St. Lawrence Market',
  'Visit the St. Lawrence Market on a Saturday morning and eat a peameal bacon sandwich from the original vendor.',
  'food', (SELECT id FROM cities WHERE name = 'Toronto'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Find the Graffiti Alley in Kensington Market',
  'Walk the full length of Rush Lane — Toronto''s famous Graffiti Alley — and document the complete wall.',
  'culture', (SELECT id FROM cities WHERE name = 'Toronto'), 'easy', 'active',
  '00000000-0000-0000-0000-000000000001', 50, 0
),
(
  'Photograph CN Tower from the Islands at sunrise',
  'Take the first ferry to the Toronto Islands and photograph the downtown skyline with the CN Tower at dawn.',
  'landmark', (SELECT id FROM cities WHERE name = 'Toronto'), 'medium', 'pending',
  '00000000-0000-0000-0000-000000000001', 100, 30
);

COMMIT;
