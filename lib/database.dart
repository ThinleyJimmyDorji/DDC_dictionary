import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/SearchResponse.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class DBProvider {
  // create a singleton
  DBProvider._();
  bool initialized;
  static final DBProvider db = DBProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "dzoDZO.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "dzoDZO.db"));

      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    return await openDatabase(
      path,
      version: 1,
    );
  }

  getResult(String controller) async {
    print("database block called");
    final db = await database;
    var res = await db.query('dz_dz',
        where: "entry like ?", whereArgs: ["$controller%"], limit: 1);
    var res2 = await db.query('dz_en',
        where: "entry like ?", whereArgs: ["$controller%"], limit: 1);
    var res3 = await db.query('en_dz',
        where: "keyword like ?",
        whereArgs: [controller.toLowerCase()],
        limit: 5);

    List<DzoSearchResponse> result1 = res.isNotEmpty
        ? res.map((note) => DzoSearchResponse.fromJson(note)).toList()
        : [];
    List<DzoSearchResponse> result2 = res2.isNotEmpty
        ? res2.map((note) => DzoSearchResponse.fromJson(note)).toList()
        : [];
    List<DzoSearchResponse> result3 = res3.isNotEmpty
        ? res3.map((note) => DzoSearchResponse.fromJson(note)).toList()
        : [];

    for (var i = 0; i < result1.length; i++) {
      result1[i].keyword = "";
      result1[i].pos = "";
    }
    for (var i = 0; i < result2.length; i++) {
      result2[i].keyword = "";
      result2[i].pos = "";
    }
    for (var i = 0; i < result3.length; i++) {
      result3[i].entry = "";
    }

    print(result3.length);

    return result1 + result2 + result3;
  }
}
