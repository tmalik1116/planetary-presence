import random

CITIES = [
    "New York City", "Los Angeles", "Chicago", "Miami", "San Francisco",
    "Toronto", "Mexico City", "Rio de Janeiro", "Buenos Aires", "Bogotá",
    "London", "Paris", "Amsterdam", "Barcelona", "Rome", "Berlin",
    "Stockholm", "Prague", "Vienna", "Athens", "Istanbul",
    "Cairo", "Cape Town", "Nairobi", "Marrakech",
    "Dubai", "Mumbai", "Delhi", "Tokyo", "Kyoto",
    "Beijing", "Shanghai", "Hong Kong", "Singapore", "Bangkok", "Bali", "Sydney",
]

QUESTS = {
    "nature": [
        ("Find the hidden waterfall", "Trek off the beaten path to discover a secluded waterfall locals rarely share with tourists."),
        ("Sunrise at the summit", "Wake before dawn and hike to the highest accessible viewpoint to watch the city wake up."),
        ("Ancient forest trail", "Walk the full length of the oldest forest trail in the region without stopping."),
        ("Spot 5 native bird species", "Using only your eyes and ears, identify 5 birds native to this region in a single outing."),
        ("Coastal tide pools", "Explore the tide pools at low tide and document 3 different marine species."),
    ],
    "culture": [
        ("Visit the oldest temple", "Find and enter the oldest temple or place of worship in the city, at least 200 years old."),
        ("Attend a local performance", "Watch a traditional music, dance, or theatre performance by local artists."),
        ("Find the street art mural", "Track down the most famous outdoor mural in the neighborhood and photograph it."),
        ("Museum after dark", "Visit a museum during a special evening or late-night opening event."),
        ("Living history walk", "Walk a self-guided historical route and find at least 4 heritage markers or plaques."),
    ],
    "food": [
        ("Eat at a century-old restaurant", "Dine at a restaurant that has been operating for at least 100 years."),
        ("Street food market crawl", "Visit the most popular street food market and try at least 4 different vendors."),
        ("Hidden café discovery", "Find a café not listed on any major app, recommended only by a local."),
        ("Order off-menu", "Visit a famous local eatery and successfully order a dish not on the printed menu."),
        ("Dawn fish market", "Arrive at the main fish or produce market before 7am and eat breakfast there."),
    ],
    "landmark": [
        ("Photograph the bridge at golden hour", "Capture the city's most iconic bridge exactly at golden hour, just before sunset."),
        ("Touch the city gate", "Find and touch the original historic city gate or wall that once marked the city boundary."),
        ("Underground passage", "Explore and navigate an underground market, tunnel, or passage hidden beneath the city."),
        ("Rooftop panorama", "Access a public rooftop with a 360-degree view and identify 5 major landmarks."),
        ("The oldest street", "Walk the full length of the oldest documented street in the city."),
    ],
}

# (quest_title, city_name) -> (lat, lng)
LOCATIONS = {
    # Photograph the bridge at golden hour
    ("Photograph the bridge at golden hour", "New York City"):    (40.7061, -73.9969),   # Brooklyn Bridge
    ("Photograph the bridge at golden hour", "London"):           (51.5055, -0.0754),    # Tower Bridge
    ("Photograph the bridge at golden hour", "Paris"):            (48.8637,  2.3133),    # Pont Alexandre III
    ("Photograph the bridge at golden hour", "Amsterdam"):        (52.3659,  4.9006),    # Magere Brug
    ("Photograph the bridge at golden hour", "Sydney"):           (-33.8523, 151.2108),  # Sydney Harbour Bridge
    ("Photograph the bridge at golden hour", "Tokyo"):            (35.6367,  139.7634),  # Rainbow Bridge
    ("Photograph the bridge at golden hour", "Prague"):           (50.0865,  14.4114),   # Charles Bridge
    ("Photograph the bridge at golden hour", "Rome"):             (41.9022,  12.4661),   # Ponte Sant'Angelo
    ("Photograph the bridge at golden hour", "Barcelona"):        (41.3784,  2.1900),    # Pont de Bac de Roda
    ("Photograph the bridge at golden hour", "Buenos Aires"):     (-34.6148, -58.3671),  # Puente de la Mujer
    ("Photograph the bridge at golden hour", "Chicago"):          (41.8885, -87.6233),   # Chicago Riverwalk
    ("Photograph the bridge at golden hour", "Istanbul"):         (41.0175,  28.9741),   # Galata Bridge
    ("Photograph the bridge at golden hour", "Singapore"):        (1.2880,   103.8523),  # Cavenagh Bridge
    ("Photograph the bridge at golden hour", "San Francisco"):    (37.8199, -122.4783),  # Golden Gate Bridge
    ("Photograph the bridge at golden hour", "Stockholm"):        (59.3244,  18.0720),   # Djurgårdsbroen
    ("Photograph the bridge at golden hour", "Vienna"):           (48.2005,  16.3699),   # Schwedenbrücke
    ("Photograph the bridge at golden hour", "Berlin"):           (52.5163,  13.3777),   # Oberbaumbrücke
    ("Photograph the bridge at golden hour", "Shanghai"):         (31.2397,  121.4896),  # Nanpu Bridge
    ("Photograph the bridge at golden hour", "Hong Kong"):        (22.2930,  114.1694),  # Tsing Ma Bridge viewpoint
    ("Photograph the bridge at golden hour", "Rio de Janeiro"):   (-22.9519, -43.2105),  # Ponte Rio-Niterói viewpoint

    # Rooftop panorama
    ("Rooftop panorama", "Paris"):          (48.8584,   2.2945),   # Eiffel Tower
    ("Rooftop panorama", "New York City"):  (40.7593,  -73.9796),  # Top of the Rock
    ("Rooftop panorama", "London"):         (51.5045,  -0.0865),   # The Shard
    ("Rooftop panorama", "Tokyo"):          (35.7101,  139.8107),  # Tokyo Skytree
    ("Rooftop panorama", "Dubai"):          (25.1972,   55.2744),  # Burj Khalifa
    ("Rooftop panorama", "Sydney"):         (-33.8704, 151.2085),  # Sydney Tower Eye
    ("Rooftop panorama", "Chicago"):        (41.8789,  -87.6359),  # Willis Tower Skydeck
    ("Rooftop panorama", "Hong Kong"):      (22.2759,  114.1455),  # Victoria Peak
    ("Rooftop panorama", "Singapore"):      (1.2838,   103.8607),  # Marina Bay Sands SkyPark
    ("Rooftop panorama", "Shanghai"):       (31.2317,  121.5054),  # Shanghai Tower
    ("Rooftop panorama", "Barcelona"):      (41.4145,   2.1527),   # Park Güell
    ("Rooftop panorama", "Cape Town"):      (-33.9628,  18.4098),  # Table Mountain
    ("Rooftop panorama", "Kuala Lumpur"):   (3.1578,   101.7123),  # KL Tower (not in cities list, harmless)
    ("Rooftop panorama", "Rome"):           (41.9022,   12.4536),  # Castel Sant'Angelo
    ("Rooftop panorama", "Athens"):         (37.9799,   23.7449),  # Lycabettus Hill
    ("Rooftop panorama", "Beijing"):        (39.9163,  116.3972),  # Jingshan Park
    ("Rooftop panorama", "Rio de Janeiro"): (-22.9519, -43.2105),  # Corcovado viewpoint
    ("Rooftop panorama", "Istanbul"):       (41.0333,   28.9775),  # Galata Tower
    ("Rooftop panorama", "Mumbai"):         (18.9220,   72.8347),  # Rajabai Clock Tower area
    ("Rooftop panorama", "Nairobi"):        (-1.2921,   36.8219),  # KICC Helipad viewpoint

    # Touch the city gate
    ("Touch the city gate", "Beijing"):     (39.9163,  116.3972),  # Tiananmen Gate
    ("Touch the city gate", "Delhi"):       (28.6129,   77.2295),  # India Gate
    ("Touch the city gate", "Rome"):        (41.9110,   12.4765),  # Porta del Popolo
    ("Touch the city gate", "Athens"):      (37.9716,   23.7260),  # Propylaea
    ("Touch the city gate", "Marrakech"):   (31.6237,   -7.9893),  # Bab Agnaou
    ("Touch the city gate", "Istanbul"):    (41.0351,   28.9861),  # Istanbul city walls (Yedikule)
    ("Touch the city gate", "London"):      (51.5137,   -0.1104),  # Temple Bar
    ("Touch the city gate", "Vienna"):      (48.2081,   16.3725),  # Burgtor
    ("Touch the city gate", "Cairo"):       (30.0626,   31.2497),  # Bab Zuweila
    ("Touch the city gate", "Nairobi"):     (-1.2921,   36.8219),  # Nairobi Railway Station gate (historic)
    ("Touch the city gate", "Prague"):      (50.0874,   14.4213),  # Powder Tower
    ("Touch the city gate", "Xi'an"):       (34.2658,  108.9541),  # Xi'an city wall (not in cities list, harmless)
    ("Touch the city gate", "Kyoto"):       (35.0038,  135.7722),  # Rashoumon area

    # Underground passage
    ("Underground passage", "New York City"):  (40.7527, -73.9772),  # Grand Central lower level
    ("Underground passage", "Tokyo"):          (35.6812, 139.7671),  # Tokyo Station underground
    ("Underground passage", "London"):         (51.5054,  -0.0910),  # Borough Market tunnels
    ("Underground passage", "Paris"):          (48.8660,   2.3431),  # Passages Couverts
    ("Underground passage", "Istanbul"):       (41.0108,  28.9681),  # Grand Bazaar
    ("Underground passage", "Rome"):           (41.8986,  12.4769),  # Pantheon underground / Palatine tunnels
    ("Underground passage", "Edinburgh"):      (55.9490,  -3.1879),  # (not in cities list, harmless)
    ("Underground passage", "Mexico City"):    (19.4268,  -99.1416), # Mercado de Medellín underground
    ("Underground passage", "Bangkok"):        (13.7463,  100.5347), # MBK Center underground
    ("Underground passage", "Singapore"):      (1.2830,   103.8510), # City Hall MRT underground links
    ("Underground passage", "Shanghai"):       (31.2304,  121.4737), # Nanjing Road pedestrian tunnel

    # Visit the oldest temple
    ("Visit the oldest temple", "Tokyo"):       (35.7148,  139.7967),  # Senso-ji
    ("Visit the oldest temple", "Kyoto"):       (34.9671,  135.7727),  # Fushimi Inari
    ("Visit the oldest temple", "Bangkok"):     (13.7465,  100.4930),  # Wat Pho
    ("Visit the oldest temple", "Athens"):      (37.9715,   23.7267),  # Parthenon
    ("Visit the oldest temple", "Istanbul"):    (41.0086,   28.9802),  # Hagia Sophia
    ("Visit the oldest temple", "Beijing"):     (39.8822,  116.4066),  # Temple of Heaven
    ("Visit the oldest temple", "Cairo"):       (30.0198,   31.2298),  # Mosque of Ibn Tulun
    ("Visit the oldest temple", "Mumbai"):      (19.0170,   72.8302),  # Siddhivinayak Temple
    ("Visit the oldest temple", "Delhi"):       (28.5244,   77.1855),  # Qutb Minar mosque
    ("Visit the oldest temple", "Bali"):        (-8.6215,  115.0865),  # Tanah Lot
    ("Visit the oldest temple", "Rome"):        (41.8986,   12.4769),  # Pantheon
    ("Visit the oldest temple", "Barcelona"):   (41.4036,    2.1744),  # Sagrada Familia
    ("Visit the oldest temple", "Singapore"):   (1.2805,   103.8468),  # Sri Mariamman Temple
    ("Visit the oldest temple", "Marrakech"):   (31.6319,   -7.9878),  # Koutoubia Mosque
    ("Visit the oldest temple", "Nairobi"):     (-1.2633,   36.8032),  # Jamia Mosque Nairobi

    # Attend a local performance
    ("Attend a local performance", "Vienna"):       (48.2030,  16.3695),  # Vienna State Opera
    ("Attend a local performance", "Sydney"):       (-33.8568, 151.2153),  # Sydney Opera House
    ("Attend a local performance", "New York City"):(40.7651, -73.9800),   # Carnegie Hall
    ("Attend a local performance", "London"):       (51.5010,  -0.1774),   # Royal Albert Hall
    ("Attend a local performance", "Paris"):        (48.8720,   2.3317),   # Opéra Garnier
    ("Attend a local performance", "Tokyo"):        (35.6845,  139.7469),  # National Theatre of Japan
    ("Attend a local performance", "Buenos Aires"): (-34.6011, -58.3833),  # Teatro Colón
    ("Attend a local performance", "Barcelona"):    (41.3808,   2.1730),   # Gran Teatre del Liceu
    ("Attend a local performance", "Prague"):       (50.0806,  14.4144),   # Prague National Theatre
    ("Attend a local performance", "Berlin"):       (52.5096,  13.3694),   # Berlin Philharmonie
    ("Attend a local performance", "Stockholm"):    (59.3327,  18.0650),   # Royal Dramatic Theatre
    ("Attend a local performance", "Amsterdam"):    (52.3667,   4.9000),   # Concertgebouw
    ("Attend a local performance", "Rome"):         (41.9047,  12.4760),   # Teatro dell'Opera di Roma
    ("Attend a local performance", "Istanbul"):     (41.0333,   28.9880),  # Zorlu Center PSM

    # Museum after dark
    ("Museum after dark", "Paris"):          (48.8606,   2.3376),   # Louvre
    ("Museum after dark", "London"):         (51.5194,  -0.1270),   # British Museum
    ("Museum after dark", "New York City"):  (40.7614,  -73.9776),  # MoMA
    ("Museum after dark", "Berlin"):         (52.5212,   13.3965),  # Pergamon Museum
    ("Museum after dark", "Rome"):           (41.9065,   12.4536),  # Vatican Museums
    ("Museum after dark", "Amsterdam"):      (52.3600,    4.8852),  # Rijksmuseum
    ("Museum after dark", "Chicago"):        (41.8796,  -87.6237),  # Art Institute of Chicago
    ("Museum after dark", "Vienna"):         (48.2036,   16.3611),  # Kunsthistorisches Museum
    ("Museum after dark", "Cairo"):          (30.0478,   31.2336),  # Egyptian Museum
    ("Museum after dark", "Athens"):         (37.9892,   23.7325),  # National Archaeological Museum
    ("Museum after dark", "Tokyo"):          (35.6664,   139.7036), # Tokyo National Museum
    ("Museum after dark", "Beijing"):        (39.9163,   116.3972), # Palace Museum (Forbidden City)
    ("Museum after dark", "Singapore"):      (1.2879,    103.8613), # National Museum of Singapore
    ("Museum after dark", "Buenos Aires"):   (-34.6037,  -58.3816), # Museo Nacional de Bellas Artes
    ("Museum after dark", "Mexico City"):    (19.4260,   -99.1757), # Museo Nacional de Antropología
    ("Museum after dark", "Mumbai"):         (18.9269,   72.8328),  # Chhatrapati Shivaji Maharaj Vastu Sangrahalaya

    # Street food market crawl
    ("Street food market crawl", "Bangkok"):       (13.7999,  100.5500),  # Chatuchak Weekend Market
    ("Street food market crawl", "Tokyo"):         (35.6654,  139.7707),  # Tsukiji Outer Market
    ("Street food market crawl", "Singapore"):     (1.3123,   103.8388),  # Newton Food Centre
    ("Street food market crawl", "Marrakech"):     (31.6258,   -7.9892),  # Djemaa el-Fna
    ("Street food market crawl", "New York City"): (40.7424,  -74.0045),  # Chelsea Market
    ("Street food market crawl", "London"):        (51.5054,   -0.0910),  # Borough Market
    ("Street food market crawl", "Istanbul"):      (41.0108,   28.9681),  # Grand Bazaar
    ("Street food market crawl", "Mexico City"):   (19.4268,  -99.1193),  # Mercado de la Merced
    ("Street food market crawl", "Mumbai"):        (18.9494,   72.8344),  # Crawford Market
    ("Street food market crawl", "Hong Kong"):     (22.3065,  114.1696),  # Temple Street Night Market
    ("Street food market crawl", "Barcelona"):     (41.3816,    2.1726),  # La Boqueria
    ("Street food market crawl", "Rome"):          (41.8919,   12.4758),  # Campo de' Fiori
    ("Street food market crawl", "Nairobi"):       (-1.2888,   36.8233),  # Maasai Market
    ("Street food market crawl", "Cairo"):         (30.0626,   31.2497),  # Khan el-Khalili Bazaar
    ("Street food market crawl", "Delhi"):         (28.6562,   77.2300),  # Chandni Chowk
    ("Street food market crawl", "Bali"):          (-8.5069,  115.2625),  # Ubud Traditional Art Market
    ("Street food market crawl", "Sydney"):        (-33.8731,  151.2049), # Chinatown Paddy's Markets
    ("Street food market crawl", "San Francisco"): (37.7955, -122.3937),  # Ferry Building Marketplace
    ("Street food market crawl", "Amsterdam"):     (52.3651,    4.9001),  # Albert Cuyp Market
    ("Street food market crawl", "Berlin"):        (52.5354,   13.4029),  # Mauerpark Flea Market

    # Dawn fish market
    ("Dawn fish market", "Tokyo"):          (35.6654,  139.7707),  # Tsukiji Outer Market
    ("Dawn fish market", "Sydney"):         (-33.8756, 151.1988),  # Sydney Fish Market
    ("Dawn fish market", "Barcelona"):      (41.3816,    2.1726),  # La Boqueria
    ("Dawn fish market", "New York City"):  (40.7064,  -74.0045),  # Fulton Fish Market
    ("Dawn fish market", "Hong Kong"):      (22.2471,  114.1507),  # Aberdeen Fish Market
    ("Dawn fish market", "Istanbul"):       (41.0233,   28.9760),  # Karaköy Fish Market
    ("Dawn fish market", "Singapore"):      (1.2805,   103.7975),  # Jurong Fish Market
    ("Dawn fish market", "Oslo"):           (59.9075,   10.7200),  # (not in cities list, harmless)
    ("Dawn fish market", "Mumbai"):         (18.9175,   72.8328),  # Sassoon Docks
    ("Dawn fish market", "Bangkok"):        (13.7298,  100.5132),  # Pak Khlong Talat flower/produce market

    # Eat at a century-old restaurant
    ("Eat at a century-old restaurant", "Paris"):          (48.8540,   2.3328),  # Café de Flore
    ("Eat at a century-old restaurant", "Vienna"):         (48.2099,  16.3669),  # Café Central
    ("Eat at a century-old restaurant", "London"):         (51.5123,  -0.1209),  # Rules Restaurant
    ("Eat at a century-old restaurant", "Rome"):           (41.9011,  12.4824),  # Antico Caffè Greco
    ("Eat at a century-old restaurant", "Prague"):         (50.0803,  14.4179),  # Café Louvre
    ("Eat at a century-old restaurant", "New York City"):  (40.7034, -74.0115),  # Fraunces Tavern
    ("Eat at a century-old restaurant", "Amsterdam"):      (52.3701,   4.8920),  # Café Hoppe
    ("Eat at a century-old restaurant", "Istanbul"):       (41.0169,  28.9730),  # Pandeli Restaurant
    ("Eat at a century-old restaurant", "Madrid"):         (40.4153,  -3.7074),  # (not in cities list, harmless)
    ("Eat at a century-old restaurant", "Barcelona"):      (41.3809,   2.1752),  # Els Quatre Gats
    ("Eat at a century-old restaurant", "Buenos Aires"):   (-34.6037, -58.3742), # Café Tortoni
    ("Eat at a century-old restaurant", "Tokyo"):          (35.7048,  139.7648), # Kanda Yabu Soba

    # Find the street art mural
    ("Find the street art mural", "New York City"):  (40.6943,  -73.9217),  # Bushwick Collective
    ("Find the street art mural", "London"):         (51.5228,   -0.0721),  # Shoreditch
    ("Find the street art mural", "Berlin"):         (52.5051,   13.4396),  # East Side Gallery
    ("Find the street art mural", "Rio de Janeiro"): (-22.9178,  -43.1781), # Santa Teresa
    ("Find the street art mural", "Buenos Aires"):   (-34.6343,  -58.3638), # El Caminito (La Boca)
    ("Find the street art mural", "Amsterdam"):      (52.4065,    4.8965),  # NDSM Wharf
    ("Find the street art mural", "Bogotá"):         ( 4.5981,   -74.0760), # La Candelaria
    ("Find the street art mural", "Bangkok"):        (13.7456,  100.4930),  # Talat Noi murals
    ("Find the street art mural", "Cape Town"):      (-33.9262,   18.4166), # Bo-Kaap
    ("Find the street art mural", "Melbourne"):      (-37.8136,  144.9631), # (not in cities list, harmless)
    ("Find the street art mural", "Singapore"):      (1.2800,   103.8440),  # Haji Lane
    ("Find the street art mural", "Miami"):          (25.7959,  -80.1990),  # Wynwood Walls

    # Living history walk
    ("Living history walk", "Rome"):          (41.8925,  12.4853),   # Roman Forum
    ("Living history walk", "Athens"):        (37.9744,  23.7310),   # Plaka district
    ("Living history walk", "Istanbul"):      (41.0054,  28.9768),   # Sultanahmet
    ("Living history walk", "Cairo"):         (30.0468,  31.2614),   # Islamic Cairo
    ("Living history walk", "Kyoto"):         (35.0038, 135.7770),   # Gion district
    ("Living history walk", "Prague"):        (50.0875,  14.4213),   # Old Town Square
    ("Living history walk", "Vienna"):        (48.2017,  16.3604),   # Ringstrasse
    ("Living history walk", "Beijing"):       (39.9290,  116.3860),  # Hutong area
    ("Living history walk", "Marrakech"):     (31.6295,  -7.9811),   # Medina
    ("Living history walk", "London"):        (51.5074,  -0.0878),   # Southwark Cathedral area
    ("Living history walk", "Edinburgh"):     (55.9490,  -3.1879),   # (not in cities list, harmless)
    ("Living history walk", "Mexico City"):   (19.4326,  -99.1332),  # Historic Centre
    ("Living history walk", "Delhi"):         (28.6562,  77.2300),   # Old Delhi / Shahjahanabad

    # Sunrise at the summit
    ("Sunrise at the summit", "Cape Town"):      (-33.9249,  18.3988),  # Lion's Head
    ("Sunrise at the summit", "Rio de Janeiro"): (-22.9519,  -43.2105), # Corcovado
    ("Sunrise at the summit", "San Francisco"):  (37.7527, -122.4477),  # Twin Peaks
    ("Sunrise at the summit", "Barcelona"):      (41.4242,    2.1582),  # Bunkers del Carmel
    ("Sunrise at the summit", "Athens"):         (37.9799,   23.7449),  # Lycabettus Hill
    ("Sunrise at the summit", "Istanbul"):       (41.0309,   29.0680),  # Çamlıca Hill
    ("Sunrise at the summit", "Kyoto"):          (34.9671,  135.7727),  # Fushimi Inari predawn hike
    ("Sunrise at the summit", "Singapore"):      (1.2574,   103.8220),  # Mount Faber
    ("Sunrise at the summit", "Sydney"):         (-33.8697,  151.2466), # Bondi to Coogee coastal walk summit
    ("Sunrise at the summit", "Bali"):           (-8.3439,  115.5094),  # Mount Batur
    ("Sunrise at the summit", "Hong Kong"):      (22.2759,  114.1455),  # Victoria Peak
    ("Sunrise at the summit", "Nairobi"):        (-1.2868,   36.8300),  # Ngong Hills viewpoint
    ("Sunrise at the summit", "Dubai"):          (25.2048,   55.2708),  # Jebel Ali Hill viewpoint
    ("Sunrise at the summit", "Tokyo"):          (35.6585,  139.7454),  # Roppongi Hills Observatory dawn

    # Ancient forest trail
    ("Ancient forest trail", "London"):      (51.4408,  -0.2760),   # Richmond Park
    ("Ancient forest trail", "New York City"):(40.7829, -73.9654),  # Central Park
    ("Ancient forest trail", "Tokyo"):        (35.6764,  139.6993), # Meiji Shrine Forest
    ("Ancient forest trail", "Singapore"):    (1.3453,   103.8302), # MacRitchie Reservoir
    ("Ancient forest trail", "Sydney"):       (-34.0853, 151.0541), # Royal National Park
    ("Ancient forest trail", "Nairobi"):      (-1.2219,   36.8176), # Karura Forest
    ("Ancient forest trail", "Cape Town"):    (-33.9714,  18.4310), # Newlands Forest
    ("Ancient forest trail", "Berlin"):       (52.4667,   13.2167), # Grunewald Forest
    ("Ancient forest trail", "Bogotá"):       ( 4.7110,  -74.0721), # Parque Nacional Natural Chingaza nearby
    ("Ancient forest trail", "Bangkok"):      (13.7563,  100.5018), # Lumphini Park (urban forest)
    ("Ancient forest trail", "Kyoto"):        (35.0116,  135.7681), # Arashiyama Bamboo Grove forest

    # Spot 5 native bird species
    ("Spot 5 native bird species", "Sydney"):      (-33.8645,  151.2166), # Royal Botanic Garden
    ("Spot 5 native bird species", "Nairobi"):     (-1.3553,   36.8464),  # Nairobi National Park
    ("Spot 5 native bird species", "Cape Town"):   (-33.9887,   18.4323), # Kirstenbosch
    ("Spot 5 native bird species", "Singapore"):   (1.4470,   103.7265),  # Sungei Buloh Wetland Reserve
    ("Spot 5 native bird species", "Bangkok"):     (13.7302,   100.5418), # Lumphini Park
    ("Spot 5 native bird species", "Bali"):        (-8.5197,   115.2628), # Sacred Monkey Forest
    ("Spot 5 native bird species", "London"):      (51.5017,    -0.1763), # St James's Park
    ("Spot 5 native bird species", "Amsterdam"):   (52.3581,    4.9000),  # Vondelpark
    ("Spot 5 native bird species", "New York City"):(40.7851,  -73.9683), # Ramble, Central Park
    ("Spot 5 native bird species", "Rio de Janeiro"):(-22.9711, -43.2172),# Tijuca Forest
    ("Spot 5 native bird species", "Buenos Aires"):(-34.5763,  -58.4194), # Reserva Ecológica
    ("Spot 5 native bird species", "Toronto"):     (43.6532,   -79.3832), # Tommy Thompson Park

    # Coastal tide pools
    ("Coastal tide pools", "Sydney"):        (-33.9173,  151.2581),  # Gordons Bay
    ("Coastal tide pools", "San Francisco"): (37.5175, -122.5166),   # Fitzgerald Marine Reserve
    ("Coastal tide pools", "Barcelona"):     (41.3746,    2.1906),   # Barceloneta
    ("Coastal tide pools", "Cape Town"):     (-34.1972,   18.4517),  # Boulders Beach
    ("Coastal tide pools", "Bali"):          (-8.6215,   115.0865),  # Tanah Lot tide pools
    ("Coastal tide pools", "Los Angeles"):   (34.0195,  -118.4912),  # Malibu tide pools
    ("Coastal tide pools", "Miami"):         (25.7617,   -80.1918),  # Virginia Key
    ("Coastal tide pools", "Tokyo"):         (35.3000,   139.6500),  # Miura Peninsula
    ("Coastal tide pools", "Istanbul"):      (40.9627,   29.0576),   # Princes' Islands coast
    ("Coastal tide pools", "Hong Kong"):     (22.2819,   114.2910),  # Clearwater Bay

    # The oldest street
    ("The oldest street", "Rome"):          (41.8919,   12.4753),   # Via Sacra
    ("The oldest street", "Athens"):        (37.9742,   23.7275),   # Panathenaic Way
    ("The oldest street", "London"):        (51.5136,   -0.0924),   # Lombard Street / Cheapside
    ("The oldest street", "Cairo"):         (30.0468,   31.2614),   # Al-Muizz Street
    ("The oldest street", "Istanbul"):      (41.0100,   28.9700),   # Divan Yolu
    ("The oldest street", "Prague"):        (50.0880,   14.4188),   # Celetná Street
    ("The oldest street", "Vienna"):        (48.2071,   16.3733),   # Kärntner Strasse
    ("The oldest street", "Tokyo"):         (35.7148,   139.7967),  # Nakamise-dori (Senso-ji approach)
    ("The oldest street", "Kyoto"):         (35.0038,   135.7770),  # Sannen-Zaka / Ninen-Zaka
    ("The oldest street", "Marrakech"):     (31.6319,   -7.9878),   # Rue des Ksour (Medina)
    ("The oldest street", "Beijing"):       (39.9290,   116.4000),  # Nanluoguxiang Hutong
}

DIFFICULTIES = ["easy", "medium", "hard", "epic"]
POINTS = {"easy": 50, "medium": 100, "hard": 200, "epic": 500}

random.seed(42)

lines = ["BEGIN;", ""]
lines.append("-- Remove previously seeded quests")
lines.append("DELETE FROM quests WHERE created_by = '44742201-8bc2-4228-ac53-f37a46204392';")
lines.append("")

for city in CITIES:
    num_quests = random.randint(3, 5)
    categories = random.choices(list(QUESTS.keys()), k=num_quests)
    for cat in categories:
        title, desc = random.choice(QUESTS[cat])
        diff = random.choice(DIFFICULTIES)
        pts = POINTS[diff]
        title_s = title.replace("'", "''")
        desc_s = desc.replace("'", "''")
        city_s = city.replace("'", "''")

        coords = LOCATIONS.get((title, city))
        if coords:
            lat_val, lng_val = coords
            lat_sql = str(lat_val)
            lng_sql = str(lng_val)
        else:
            lat_sql = "NULL"
            lng_sql = "NULL"

        lines.append(
            f"INSERT INTO quests (id, title, description, category, difficulty, status, city_id, created_by, current_points, lat, lng) "
            f"SELECT gen_random_uuid(), '{title_s}', '{desc_s}', '{cat}', '{diff}', 'active', "
            f"id, '44742201-8bc2-4228-ac53-f37a46204392', {pts}, {lat_sql}, {lng_sql} "
            f"FROM cities WHERE name = '{city_s}' LIMIT 1;"
        )

lines += ["", "COMMIT;"]
print("\n".join(lines))
