import 'package:sqflite/sqflite.dart';

import '../models/dictionary_entry.dart';
import '../models/dictionary_source.dart';
import 'database_helper.dart';

/// All reads/writes against the dictionary database go through here --
/// searching, favorites, history, and the word of the day.
///
/// Search strategy: detect whether the query is Dzongkha (Tibetan script)
/// or Latin script, then try an indexed prefix match on the headword first
/// (fast, and matches how people actually look words up). If that finds
/// nothing, fall back to an FTS5 search over definitions, so a query that
/// describes a *meaning* rather than a headword still surfaces something --
/// the old app's `LIKE` scan had no equivalent to this.
class DictionaryRepository {
  DictionaryRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static final _tibetanScriptPattern = RegExp('[ༀ-࿿]');

  bool _looksLikeDzongkha(String text) => _tibetanScriptPattern.hasMatch(text);

  Future<List<DictionaryEntry>> search(String rawQuery, {int limit = 40}) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return const [];

    final db = await _dbHelper.database;
    final sources = _looksLikeDzongkha(query)
        ? const [DictionarySource.dzDz, DictionarySource.dzEn]
        : const [DictionarySource.enDz];

    final prefixResults = await _prefixSearch(db, sources, query, limit);
    if (prefixResults.isNotEmpty) return prefixResults;

    return _definitionSearch(db, sources, query, limit);
  }

  Future<List<DictionaryEntry>> _prefixSearch(
    Database db,
    List<DictionarySource> sources,
    String query,
    int limit,
  ) async {
    final results = <DictionaryEntry>[];
    for (final source in sources) {
      final rows = await db.query(
        source.table,
        where: '${source.headwordColumn} LIKE ?',
        whereArgs: ['$query%'],
        orderBy: '${source.headwordColumn} COLLATE NOCASE ASC',
        limit: limit,
      );
      results.addAll(rows.map((row) => DictionaryEntry.fromRow(source, row)));
    }
    return results;
  }

  Future<List<DictionaryEntry>> _definitionSearch(
    Database db,
    List<DictionarySource> sources,
    String query,
    int limit,
  ) async {
    final ftsQuery = _sanitizeFtsQuery(query);
    if (ftsQuery.isEmpty) return const [];

    final results = <DictionaryEntry>[];
    for (final source in sources) {
      try {
        final rows = await db.rawQuery(
          '''
          SELECT t.* FROM ${source.table} t
          JOIN ${source.table}_fts f ON f.rowid = t.id
          WHERE ${source.table}_fts MATCH ?
          LIMIT ?
          ''',
          [ftsQuery, limit],
        );
        results.addAll(rows.map((row) => DictionaryEntry.fromRow(source, row)));
      } on DatabaseException {
        // Malformed FTS query syntax (e.g. a lone operator) -- treat as no
        // matches rather than crashing the search.
        continue;
      }
    }
    return results;
  }

  /// FTS5's MATCH syntax treats quotes/operators specially. Strip anything
  /// that isn't a word character or Tibetan script, then request a prefix
  /// match on the (last) term so partial typing still finds results.
  String _sanitizeFtsQuery(String query) {
    final cleaned =
        query.replaceAll(RegExp(r'[^\wༀ-࿿\s]'), ' ').trim();
    if (cleaned.isEmpty) return '';
    return '$cleaned*';
  }

  /// Deterministic "word of the day" -- same word all day, changes daily,
  /// no network/server needed.
  Future<DictionaryEntry?> wordOfTheDay() async {
    final db = await _dbHelper.database;
    const source = DictionarySource.dzEn;
    final countRows = await db.rawQuery('SELECT COUNT(*) AS c FROM ${source.table}');
    final count = countRows.first['c'] as int;
    if (count == 0) return null;

    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final targetId = (seed % count) + 1;

    var rows = await db.query(source.table, where: 'id = ?', whereArgs: [targetId], limit: 1);
    if (rows.isEmpty) {
      // Id gaps shouldn't exist after migration, but don't crash if they do.
      rows = await db.query(source.table, limit: 1, offset: seed % count);
    }
    if (rows.isEmpty) return null;
    return DictionaryEntry.fromRow(source, rows.first);
  }

  Future<bool> isFavorite(DictionaryEntry entry) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'favorites',
      where: 'source = ? AND entry_id = ?',
      whereArgs: [entry.source.table, entry.id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> addFavorite(DictionaryEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert(
      'favorites',
      {
        'source': entry.source.table,
        'entry_id': entry.id,
        'headword': entry.headword,
        'pos': entry.pos,
        'definition': entry.definition,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(DictionaryEntry entry) async {
    final db = await _dbHelper.database;
    await db.delete(
      'favorites',
      where: 'source = ? AND entry_id = ?',
      whereArgs: [entry.source.table, entry.id],
    );
  }

  Future<List<DictionaryEntry>> getFavorites() async {
    final db = await _dbHelper.database;
    final rows = await db.query('favorites', orderBy: 'created_at DESC');
    return rows.map(DictionaryEntry.fromFavoriteRow).toList();
  }

  Future<void> addHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final db = await _dbHelper.database;

    // Move re-searched terms back to the top instead of listing them twice.
    await db.delete('history', where: 'query = ?', whereArgs: [trimmed]);
    await db.insert('history', {
      'query': trimmed,
      'searched_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Keep history from growing unbounded.
    await db.rawDelete('''
      DELETE FROM history WHERE id NOT IN (
        SELECT id FROM history ORDER BY searched_at DESC LIMIT 50
      )
    ''');
  }

  Future<List<String>> getRecentHistory({int limit = 10}) async {
    final db = await _dbHelper.database;
    final rows = await db.query('history', orderBy: 'searched_at DESC', limit: limit);
    return rows.map((row) => row['query'] as String).toList();
  }

  Future<void> clearHistory() async {
    final db = await _dbHelper.database;
    await db.delete('history');
  }
}
