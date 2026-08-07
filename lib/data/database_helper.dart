import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Opens (and, on first launch, installs) the bundled dictionary database.
///
/// Filename is deliberately different from the old app's `dzoDZO.db`: if
/// someone upgrades in place from the old app, we don't want to accidentally
/// pick up a stale copy with the old schema (no indexes, no FTS tables, no
/// history/meta). A new filename guarantees a clean install of the new
/// schema regardless of upgrade path.
class DatabaseHelper {
  DatabaseHelper._({Directory? directoryOverride})
      : _directoryOverride = directoryOverride;
  static final DatabaseHelper instance = DatabaseHelper._();

  /// For widget/unit tests: `path_provider` is a platform-channel plugin
  /// with no implementation under plain `flutter test`, so tests inject a
  /// directory they control (e.g. a temp dir) instead of hitting it.
  /// Override [repository_providers.databaseHelperProvider] with this in
  /// tests rather than using [instance].
  factory DatabaseHelper.forTesting(Directory directory) =>
      DatabaseHelper._(directoryOverride: directory);

  final Directory? _directoryOverride;

  static const _dbFileName = 'ddc_dictionary.db';
  static const _assetPath = 'assets/db/ddc_dictionary.db';

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    final opened = await _open();
    _database = opened;
    return opened;
  }

  Future<Database> _open() async {
    if (kIsWeb) {
      return _openWeb();
    }
    return _openNative();
  }

  Future<Database> _openWeb() async {
    final dbPath = _dbFileName;

    if (!await databaseExists(dbPath)) {
      final data = await rootBundle.load(_assetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await databaseFactory.writeDatabaseBytes(dbPath, bytes);
    }

    return openDatabase(dbPath, version: 1);
  }

  Future<Database> _openNative() async {
    final baseDir =
        _directoryOverride ?? await getApplicationSupportDirectory();
    final dbPath = p.join(baseDir.path, _dbFileName);

    if (!await databaseExists(dbPath)) {
      try {
        await Directory(p.dirname(dbPath)).create(recursive: true);
      } catch (_) {}

      final data = await rootBundle.load(_assetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(dbPath, version: 1);
  }
}
