# Planetary Presence — Agent Guide

## Project

Flutter app. Gamified travel tracker — users complete location-based quests worldwide, earn points, compete on leaderboards.

**Tagline:** Explore the globe and establish your planetary presence.

---

## Agent Rules

### Git
- Commit frequently as you work — after each logical unit (new file, feature complete, dependency added, etc.)
- Commit message format: conventional commits (`feat:`, `fix:`, `chore:`, `refactor:`)
- Never force push. Never skip hooks.

### CLAUDE.md Updates
Update this file when any of the following change:
- New packages added to `pubspec.yaml`
- New screens/pages created
- Firebase or backend setup changed
- Folder structure reorganized
- Architecture decisions made
- DB schema defined or changed
- New environment variables or config files added

Add a dated entry under **Changelog** at the bottom of this file.

### Build / Run
**Never** run `flutter run`, `flutter build`, or any command that launches/validates the app. These fail or hang in this environment. When build validation is needed, tell the user what command to run and what to look for.

### Hot Reload Warning
If changes include any of the following, explicitly tell the user **"This requires a full restart (`flutter run`), not hot reload"**:
- New packages added to `pubspec.yaml`
- Changes to `AndroidManifest.xml` or `Info.plist`
- New native plugins integrated
- Changes to `android/` or `ios/` build files
- Asset additions to `pubspec.yaml`

### Human Validation
**Before closing any GitHub issue**, ask the user to manually test the feature on device and confirm it works. Do not close the issue until the user explicitly says it's good. State clearly what to test and what the expected behavior is.

### Issue Assignment
**When starting work on a GitHub issue**, immediately assign it to `m-GDEV` so the partner knows it's in progress:
```
gh issue edit <number> --add-assignee m-GDEV --repo tmalik1116/planetary-presence
```

### Code Style
- Dart/Flutter conventions. No unnecessary comments.
- Widgets in `lib/screens/` or `lib/widgets/` as appropriate.
- State management TBD — await direction from user before choosing.
- Keep files focused. Split large widgets.

---

## App Architecture

### Navigation
Bottom navbar — 5 tabs:

```
[ Map ]  [ Quests ]  [ + ]  [ Stats ]  [ Profile ]
```

Central `+` button = primary action (record/complete quest). Visually distinct from other tabs.

### Screens

| Screen | Purpose |
|--------|---------|
| Map | Interactive world map, city pins, tap to see quests |
| Quests | List nearby active quests, vote on pending, submit new |
| Record | Complete a quest or add details (central nav button) |
| Stats | Points, cities visited, quests done, activity graph |
| Profile | Home city, settings entry point |
| Charts | Leaderboard + other charts (`fl_charts`) |

### Quest System
- Quests scoped to cities (groupable by country)
- Categories: Nature, Culture, Food, Landmarks
- User-submitted, community-voted
- Points vary by difficulty/rarity (dynamic assignment)
- Home city quests: 2x points

### Points & Leaderboard
- Leaderboard tiers: Local → City → State → Country → Global
- Friend leaderboard available

---

## Current Stack

| Layer | Package | Status |
|-------|---------|--------|
| Flutter SDK | `flutter` | ✅ initialized |
| Icons | `cupertino_icons ^1.0.8` | ✅ |
| Charts | `fl_charts` | planned |
| Maps | flutter_map ^8.1.1 + latlong2 ^0.9.1 | ✅ |
| Backend | Supabase | ✅ `supabase_flutter ^2.8.4` |
| Auth | Supabase Auth + google_sign_in ^6.2.2 | ✅ |
| Database | Supabase Postgres + PostGIS | ✅ migration SQL ready |
| Location | `geolocator ^13.0.2` | ✅ |
| State mgmt | TBD | pending decision |

---

## Folder Structure (target)

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
    ...
  models/
    quest.dart
    user.dart
    ...
  config/
    supabase_config.dart
  services/
    supabase_service.dart
    ...
```

---

## First Steps Checklist

- [x] App shell — `MaterialApp` + bottom navbar scaffold
- [x] 5 placeholder screens wired to navbar
- [x] Supabase project setup + `pubspec.yaml` deps (`supabase_flutter ^2.8.4`)
- [x] DB schema design (`supabase/migrations/001_initial_schema.sql`)
- [x] Supabase initialization in app (`lib/main.dart`, `lib/config/supabase_config.dart`)

---

## Changelog

| Date | Change | Agent |
|------|--------|-------|
| 2026-05-09 | CLAUDE.md created, README reformatted | main |
| 2026-05-09 | App shell created: MainShell + 5 screens + bottom nav | subagent |
| 2026-05-09 | Supabase integration: config, service, migration SQL | subagent |
| 2026-05-09 | Quest model + QuestService CRUD | subagent |
| 2026-05-09 | Quests screen: Active/Pending tabs, QuestCard, create form wired to Supabase | subagent |
| 2026-05-10 | AppLogger: console + file logging, wired to QuestService and ProfileScreen | subagent |
| 2026-05-10 | Light mode + Settings screen with theme toggle | subagent |
| 2026-05-10 | Auth: email/password + Google OAuth, onboarding (username + home city) | subagent |
| 2026-05-10 | Design system: AppTheme, AppColors, AppSpacing, redesigned nav + cards | subagent |
| 2026-05-10 | GPS location service, user coordinates update on login | subagent |
| 2026-05-10 | Map screen: flutter_map integration, OSM tiles, placeholder city markers | subagent |
