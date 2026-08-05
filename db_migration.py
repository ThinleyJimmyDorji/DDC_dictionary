#!/usr/bin/env python3
"""
Migrates the old, index-free dzoDZO.db (dz_dz / dz_en / en_dz tables with no
primary keys or indexes) into a new ddc_dictionary.db with:
  - proper integer primary keys on every table (en_dz had none before)
  - btree indexes on the columns every search hits (entry / keyword)
  - FTS5 external-content virtual tables over definitions, for a
    "search by meaning" fallback when prefix search finds nothing
  - new, empty favorites / history tables for the app's new features
  - a meta table recording schema version + row counts for future sanity checks

Usage: python3 db_migration.py <old_db_path> <new_db_path>
"""
import sqlite3
import sys
import time

SCHEMA_VERSION = 1


def create_schema(new: sqlite3.Connection) -> None:
    cur = new.cursor()
    cur.executescript(
        """
        PRAGMA foreign_keys = ON;

        CREATE TABLE dz_dz (
            id INTEGER PRIMARY KEY,
            entry TEXT NOT NULL,
            definition TEXT NOT NULL
        );
        -- COLLATE NOCASE so SQLite's LIKE-to-range-scan optimization can use
        -- this index (LIKE is case-insensitive by default; without a NOCASE
        -- collated index the planner falls back to a full table scan since
        -- a BINARY-ordered index can't safely represent case-insensitive
        -- prefix ranges).
        CREATE INDEX idx_dz_dz_entry ON dz_dz(entry COLLATE NOCASE);

        CREATE TABLE dz_en (
            id INTEGER PRIMARY KEY,
            entry TEXT NOT NULL,
            pos TEXT,
            definition TEXT NOT NULL
        );
        CREATE INDEX idx_dz_en_entry ON dz_en(entry COLLATE NOCASE);

        CREATE TABLE en_dz (
            id INTEGER PRIMARY KEY,
            keyword TEXT NOT NULL,
            pos TEXT,
            definition TEXT NOT NULL
        );
        CREATE INDEX idx_en_dz_keyword ON en_dz(keyword COLLATE NOCASE);

        -- FTS5 external-content tables: no data duplication, just an index
        -- over the same rows, kept in sync via the rowid = source table id.
        CREATE VIRTUAL TABLE dz_dz_fts USING fts5(
            entry, definition, content='dz_dz', content_rowid='id'
        );
        CREATE VIRTUAL TABLE dz_en_fts USING fts5(
            entry, definition, content='dz_en', content_rowid='id'
        );
        CREATE VIRTUAL TABLE en_dz_fts USING fts5(
            keyword, definition, content='en_dz', content_rowid='id'
        );

        CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source TEXT NOT NULL,               -- 'dz_dz' | 'dz_en' | 'en_dz'
            entry_id INTEGER NOT NULL,           -- id in the source table
            headword TEXT NOT NULL,
            pos TEXT,
            definition TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            UNIQUE(source, entry_id)
        );

        CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT NOT NULL,
            searched_at INTEGER NOT NULL
        );

        CREATE TABLE meta (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );
        """
    )
    new.commit()


def migrate_dz_dz(old: sqlite3.Connection, new: sqlite3.Connection) -> int:
    rows = old.execute("SELECT id, entry, definition FROM dz_dz ORDER BY id").fetchall()
    new.executemany("INSERT INTO dz_dz (id, entry, definition) VALUES (?, ?, ?)", rows)
    new.commit()
    return len(rows)


def migrate_dz_en(old: sqlite3.Connection, new: sqlite3.Connection) -> int:
    rows = old.execute("SELECT id, entry, pos, definition FROM dz_en ORDER BY id").fetchall()
    new.executemany(
        "INSERT INTO dz_en (id, entry, pos, definition) VALUES (?, ?, ?, ?)", rows
    )
    new.commit()
    return len(rows)


def migrate_en_dz(old: sqlite3.Connection, new: sqlite3.Connection) -> int:
    # old en_dz has no id column at all -- assign one on the way in, ordered
    # by rowid so the mapping is stable/reproducible.
    rows = old.execute(
        "SELECT rowid, keyword, pos, definition FROM en_dz ORDER BY rowid"
    ).fetchall()
    new.executemany(
        "INSERT INTO en_dz (id, keyword, pos, definition) VALUES (?, ?, ?, ?)", rows
    )
    new.commit()
    return len(rows)


def populate_fts(new: sqlite3.Connection) -> None:
    cur = new.cursor()
    cur.execute(
        "INSERT INTO dz_dz_fts(rowid, entry, definition) SELECT id, entry, definition FROM dz_dz"
    )
    cur.execute(
        "INSERT INTO dz_en_fts(rowid, entry, definition) SELECT id, entry, definition FROM dz_en"
    )
    cur.execute(
        "INSERT INTO en_dz_fts(rowid, keyword, definition) SELECT id, keyword, definition FROM en_dz"
    )
    new.commit()


def write_meta(new: sqlite3.Connection, counts: dict) -> None:
    cur = new.cursor()
    rows = [
        ("schema_version", str(SCHEMA_VERSION)),
        ("generated_at", str(int(time.time()))),
        ("dz_dz_count", str(counts["dz_dz"])),
        ("dz_en_count", str(counts["dz_en"])),
        ("en_dz_count", str(counts["en_dz"])),
    ]
    cur.executemany("INSERT INTO meta (key, value) VALUES (?, ?)", rows)
    new.commit()


def verify(old: sqlite3.Connection, new: sqlite3.Connection, counts: dict) -> None:
    for table in ("dz_dz", "dz_en", "en_dz"):
        old_count = old.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        new_count = new.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        assert old_count == new_count == counts[table], (
            f"count mismatch for {table}: old={old_count} new={new_count} "
            f"migrated={counts[table]}"
        )

    # FTS row counts should match their source tables.
    for table in ("dz_dz", "dz_en", "en_dz"):
        src_count = new.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        fts_count = new.execute(f"SELECT COUNT(*) FROM {table}_fts").fetchone()[0]
        assert src_count == fts_count, f"FTS row count mismatch for {table}_fts"

    # Spot-check a known entry survives migration with identical definition.
    old_a = old.execute(
        "SELECT definition FROM en_dz WHERE keyword = 'aardvark' LIMIT 1"
    ).fetchone()
    new_a = new.execute(
        "SELECT definition FROM en_dz WHERE keyword = 'aardvark' LIMIT 1"
    ).fetchone()
    assert old_a == new_a, "spot-check mismatch on 'aardvark'"

    # Prefix search should use the index (EXPLAIN QUERY PLAN should not
    # mention SCAN on the source table).
    plan = new.execute(
        "EXPLAIN QUERY PLAN SELECT * FROM en_dz WHERE keyword LIKE 'wor%'"
    ).fetchall()
    plan_text = " ".join(row[-1] for row in plan)
    assert "USING INDEX" in plan_text or "SEARCH" in plan_text, (
        f"prefix search does not appear to use an index: {plan_text}"
    )

    # FTS search should find something for a word only present in a
    # definition, not as a headword.
    fts_hit = new.execute(
        "SELECT en_dz.keyword FROM en_dz JOIN en_dz_fts ON en_dz.id = en_dz_fts.rowid "
        "WHERE en_dz_fts MATCH 'pumpkin' LIMIT 5"
    ).fetchall()
    assert len(fts_hit) > 0, "expected at least one FTS hit for 'pumpkin'"


def main() -> None:
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    old_path, new_path = sys.argv[1], sys.argv[2]

    old = sqlite3.connect(old_path)
    new = sqlite3.connect(new_path)

    create_schema(new)

    counts = {
        "dz_dz": migrate_dz_dz(old, new),
        "dz_en": migrate_dz_en(old, new),
        "en_dz": migrate_en_dz(old, new),
    }
    populate_fts(new)
    write_meta(new, counts)
    new.execute("VACUUM")
    new.commit()

    verify(old, new, counts)

    print("Migration OK.")
    print("Row counts:", counts)
    print("New DB path:", new_path)

    old.close()
    new.close()


if __name__ == "__main__":
    main()
