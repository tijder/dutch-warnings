# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run (pick a target)
flutter run -d android
flutter run -d linux
flutter run -d chrome

# Analyze
flutter analyze

# Test
flutter test
flutter test test/widget_test.dart          # single test file

# Build
flutter build apk --release
flutter build linux --release
flutter build web --release

# Code generation (run after changing routes or ARB files)
flutter gen-l10n                                          # translations
dart run build_runner build --delete-conflicting-outputs  # auto_route router

# Docusaurus docs site
cd website && npm install && npm start   # http://localhost:3000/
```

## Architecture

**State management** — Riverpod (`StateNotifierProvider` / `FutureProvider`). All providers live in `lib/providers/`.

**Navigation** — `auto_route`. Routes are declared in `lib/router/app_router.dart`; the generated file is `app_router.gr.dart`. Adding a screen requires `@RoutePage()` on the widget class, a new `AutoRoute` entry, and re-running `build_runner`. Deep links for `/warning/:id` and `/settings` are handled in `main.dart`.

**Data flow**:
1. `ApiService` fetches from `https://api.public-warning.app/api/v1/providers/nl-alert/alerts` (cursor pagination via `?after=<id>`).
2. `CacheService` persists to Hive box `alerts_v1`; alerts are keyed by ID and returned sorted newest-first.
3. `AlertsNotifier` (in `alertsProvider`) loads cache first, then refreshes from the API. Supports `refresh()`, `loadMore()`, and `loadAll()`.
4. `NotificationWatcher` listens to `alertsProvider`, skips the first load (seeding seen-IDs), and calls `NotificationService` for any new active alerts. Alerts whose area contains the user's location get sound; others get vibration only.

**Screens** — `MainScreen` is a tab shell using `AutoTabsRouter` with `NavigationBar` on narrow screens and `NavigationRail` on wide (≥ 600 px). Tabs: List → Map → Stats → Settings. Detail is a full-screen push route (`/warning/:id`).

**Localisation** — Dutch (`app_nl.arb`) is the template; English (`app_en.arb`) mirrors it. Use `context.l10n.<key>` in widgets. After changing ARB files run `flutter gen-l10n`.

**Settings persistence** — `SettingsService` uses Hive box `settings_v1`. `SettingsState` is exposed via `settingsProvider`.

**Geo utilities** — `lib/utils/geo_utils.dart` contains polygon parsing (`"lat,lng lat,lng …"` format used in `Alert.area`) and a ray-casting point-in-polygon check used by the notification watcher.

**Alert message format** — The raw `message` field uses `***` as a separator between Dutch and English text. Use `alert.dutchMessage`, `alert.englishMessage`, or `alert.title` (first sentence of Dutch text).

**Platform notes** — `url_strategy_stub.dart` / `url_strategy_web.dart` configure path-based URL routing for web only (conditional import). `NotificationService` is a no-op on web (`kIsWeb` guard).

**Debug mode** — In debug builds, enabling `debugInjectAlert` via Settings injects a fake alert into the list on every refresh.
