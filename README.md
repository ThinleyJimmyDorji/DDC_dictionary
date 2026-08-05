# DDC Dictionary — v2

A Dzongkha ↔ English dictionary app for the Dzongkha Development Commission
(རྫོང་ཁ་གོང་འཕེལ་ལྷན་ཚོགས།). This is a ground-up rewrite of the original
Flutter app, focused on an actually-working search experience, modern
Material 3 UI, and a few new features (favorites, history, word of the day,
dark mode).

## What changed from v1

- **Search actually works now.** The old app's search field only returned
  results if you tapped a suggestion from a hardcoded English word list
  that was never connected to the real dictionary — free typing didn't
  reliably search anything. This version searches live as you type
  (debounced), in either script.
- **Indexed + full-text search.** The old database had zero indexes, so
  every lookup was a full table scan. The new database
  (`assets/db/ddc_dictionary.db`, built by `../db_migration.py` from the
  original `dzoDZO.db`) adds proper indexes on every headword column, plus
  FTS5 tables so a query that doesn't match a headword prefix falls back
  to a "search by meaning" pass over definitions.
- **New features:** favorites, recent search history, a deterministic
  word of the day, dark mode, and an adjustable text size for the
  Dzongkha script.
- **State management:** Riverpod, replacing the old app's hand-rolled
  `StreamController`-based "bloc".
- **Navigation:** search is the primary destination (bottom nav: Search /
  Favorites / Settings), instead of being buried behind a button in a
  middle tab.

## Project layout

```
lib/
  main.dart, app.dart          entry point, MaterialApp + theme wiring
  theme/app_theme.dart         Material 3 light/dark theme, Dzongkha text style
  models/                      DictionaryEntry, DictionarySource
  data/                        DatabaseHelper (asset DB install), DictionaryRepository
  providers/                   Riverpod providers (search, favorites, history, settings)
  screens/                     HomeScreen shell + each tab/screen
  widgets/                     EntryCard, EmptyState, SectionHeader
```

## Database

`assets/db/ddc_dictionary.db` is generated, not hand-written. To regenerate
it from a fresh copy of the original `dzoDZO.db`:

```
python3 db_migration.py /path/to/dzoDZO.db assets/db/ddc_dictionary.db
```

The script recreates `dz_dz`, `dz_en`, `en_dz` with proper primary keys and
`COLLATE NOCASE` indexes on the headword columns (needed for SQLite's
LIKE-to-index-range-scan optimization on case-insensitive prefix search),
adds FTS5 external-content tables for definition search, and adds new
`favorites`, `history`, and `meta` tables. It verifies row counts against
the source database and checks that prefix search actually uses the index
before writing the output.

## Building

```
flutter pub get
flutter run
```

Requires Flutter >= 3.22 (uses newer Material 3 `ColorScheme` surface
tokens). Android/iOS platform folders were carried over unchanged from the
original project (they're not app-specific beyond icons/package id, which
are unchanged).

## Known limitations / next steps

- This was built without access to a local Flutter toolchain (sandboxed
  dev environment had no network path to the Dart SDK), so it hasn't been
  run through `flutter pub get` / `flutter analyze` / an emulator yet.
  Every file was hand-reviewed for import correctness and the SQL layer
  was fully tested against the real data via a Python harness, but you
  should run `flutter analyze` and do a manual smoke test before treating
  this as done.
- `flutter_launcher_icons` / `flutter_native_splash` are declared as dev
  dependencies but haven't been re-run — the app icon/splash still come
  from the old project's generated output. Run
  `flutter pub run flutter_launcher_icons` if you want to regenerate them.
- No automated tests yet (widget tests or repository unit tests would be
  a good next addition, especially around the search fallback logic).
