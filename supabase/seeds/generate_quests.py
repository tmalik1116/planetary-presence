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

DIFFICULTIES = ["easy", "medium", "hard", "epic"]
POINTS = {"easy": 50, "medium": 100, "hard": 200, "epic": 500}

random.seed(42)

lines = ["BEGIN;", ""]

for city in CITIES:
    num_quests = random.randint(3, 5)
    categories = random.choices(list(QUESTS.keys()), k=num_quests)
    for cat in categories:
        title, desc = random.choice(QUESTS[cat])
        diff = random.choice(DIFFICULTIES)
        pts = POINTS[diff]
        # escape single quotes
        title_s = title.replace("'", "''")
        desc_s = desc.replace("'", "''")
        city_s = city.replace("'", "''")
        lines.append(
            f"INSERT INTO quests (id, title, description, category, difficulty, status, city_id, created_by, current_points) "
            f"SELECT gen_random_uuid(), '{title_s}', '{desc_s}', '{cat}', '{diff}', 'active', "
            f"id, '44742201-8bc2-4228-ac53-f37a46204392', {pts} "
            f"FROM cities WHERE name = '{city_s}' LIMIT 1;"
        )

lines += ["", "COMMIT;"]
print("\n".join(lines))
