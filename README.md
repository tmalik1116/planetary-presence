# Trailblazer

> **Explore the globe and establish your planetary presence.**

---

## Idea

Consolidate the various aspects of travel and cultural exploration into one gamified experience. Users complete location-based quests across cities, earning points and competing globally.

---

## Quest Categories

| Category | Example |
|----------|---------|
| Nature | Find a thorny devil in Australia and take a photo |
| Culture | Participate in Holi street dancing in India |
| Food | Eat sushi in Tokyo |
| Landmarks | Visit the Eiffel Tower in Paris |

- Quests are user-submitted and community-voted
- Rarity/difficulty determines point value — rarer quests worth more points (dynamically assigned)
- Quests scoped to cities, groupable by country

---

## Points System

- Points earned by completing quests
- Leaderboard tiers: Local → City → State → Country → Global
- Home city bonus: 2x points for quests in user's home city

---

## App Features

### Map
- Interactive map with pins/popups per city/area
- Tap city to view its quests only
- Side menu filters: completion status, friends, popular, category (Nature, Landmark, Food, Culture, etc.)

### Quests
- List of active quests nearby
- Vote on pending community quests
- Submit new quests

### Record (Central Nav Button)
- Main CTA to complete a quest or add details

### Stats
- Total points, cities visited, quests completed, current-year points
- GitHub-style activity graph for quest completions

### Charts
- Leaderboard view
- Other charts (TBD) via `fl_charts`

### Profile
- Display home city
- Entry point to settings

---

## Navigation

Bottom navbar — 5 items:

```
[ Map ]  [ Quests ]  [ + ]  [ Stats ]  [ Profile ]
```

Central `+` button contrasts others visually — primary action.

---

## First Steps

- [ ] Main app shell with bottom navbar
- [ ] Firebase DB setup and initialization
- [ ] DB schema/structure design
