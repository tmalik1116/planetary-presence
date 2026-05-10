# Planetary Presence — Architecture

## Tech Stack

| Layer | Tech | Version | Status |
|-------|------|---------|--------|
| App | Flutter | SDK | ✅ |
| Backend | Supabase | — | ✅ |
| Database | Supabase Postgres + PostGIS | — | ✅ |
| Auth | Supabase Auth + Google Sign-In | `google_sign_in ^6.2.2` | ✅ |
| Icons | cupertino_icons | `^1.0.8` | ✅ |
| Charts | fl_charts | — | planned |
| Maps | TBD | — | pending |
| State mgmt | TBD | — | pending |

### Notes
- Google OAuth brokered through Supabase Auth — not standalone Google Cloud
- PostGIS extension on Postgres powers location/city spatial queries

---

## Navigation

Bottom navbar — 5 tabs:

```
[ Map ]  [ Quests ]  [ + ]  [ Stats ]  [ Profile ]
```

Central `+` = primary action (record/complete quest). Visually distinct.

---

## Screens

| Screen | Purpose |
|--------|---------|
| Map | Interactive world map, city pins, tap to see quests |
| Quests | List nearby active quests, vote on pending, submit new |
| Record | Complete a quest or add details (central nav button) |
| Stats | Points, cities visited, quests done, activity graph |
| Profile | Home city, settings entry point |
| Charts | Leaderboard + other charts |

---

## Quest System

- Scoped to cities (groupable by country)
- Categories: Nature, Culture, Food, Landmarks
- User-submitted, community-voted
- Points vary by difficulty/rarity (dynamic assignment)
- Home city quests: 2x points

---

## Points & Leaderboard

- Tiers: Local → City → State → Country → Global
- Friend leaderboard available

---

## Folder Structure

```
lib/
  main.dart
  screens/
    map_screen.dart
    quests_screen.dart
    record_screen.dart
    stats_screen.dart
    profile_screen.dart
    charts_screen.dart
  widgets/
    bottom_nav.dart
    quest_card.dart
  models/
    quest.dart
    user.dart
  config/
    supabase_config.dart
  services/
    supabase_service.dart
```

---

## DB Schema

Migration: `supabase/migrations/001_initial_schema.sql`

_(schema detail TBD — add tables/columns here as defined)_

---

## Changelog

| Date | Change |
|------|--------|
| 2026-05-10 | Initial architecture.md created |
