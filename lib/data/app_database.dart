import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  Database? _db;
  final String _dictionaryTableName = "Dictionary";
  final String _colWord = "word";

  final String _sampleTableName = "Sample";
  final String _colId = "id";
  final String _colName = "name";
  final String _colDescription = "description";
  final String _colSegmentedText = "segmented_text";
  final String _colTopicLabels = "topic_labels";
  final String _colStanceLabel = "stance_label";
  final String _colCreatedAt = "created_at";
  final String _colQuality = "quality";

  static final AppDatabase instance = AppDatabase._constructor();
  AppDatabase._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _getDatabase();
    return _db!;
  }

  Future<Database> _getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "kh_vector_db.db");

    // Reset everything DEVELOPMENT ONLY
    await deleteDatabase(databasePath);

    Database database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE IF NOT EXISTS $_dictionaryTableName(
            $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colWord TEXT NOT NULL
          )
      ''');

        db.execute('''
          CREATE TABLE IF NOT EXISTS $_sampleTableName (
            $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colName TEXT,
            $_colDescription TEXT,
            $_colSegmentedText TEXT,
            $_colTopicLabels TEXT,
            $_colStanceLabel INTEGER,
            $_colCreatedAt TEXT,
            $_colQuality REAL
          )
      ''');
      },
    );
    return database;
  }

  Future<List<String>> getAllWords() async {
    final db = await database;
    final resultQuery = await db.query(_dictionaryTableName);
    List<String> result = [];
    if (resultQuery.isEmpty) {
      List<String> wordList = await readLinesFromAssets(
        "assets/factory_dictionary.txt",
      );
      final batch = db.batch();
      for (final word in wordList) {
        batch.insert(_dictionaryTableName, {_colWord: word});
      }
      await batch.commit();
      result = wordList;
      print("Asset is used");
    } else {
      for (final record in resultQuery) {
        result.add(record[_colWord].toString());
      }
      print("database is used");
    }
    return result;
  }

  // utf8.decode ensures that Khmer characters (which are multi-byte) are never
  // cut in half during the process.
  Future<List<String>> readLinesFromAssets(String path) async {
    // 1. Get the raw byte stream from the asset bundle
    final ByteData data = await rootBundle.load(path);

    // 2. Convert bytes to a list of clean strings
    return utf8
        .decode(data.buffer.asUint8List())
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<List<Sample>> getAllSamples() async {
    final db = await database;
    final resultQuery = await db.query(_sampleTableName);
    List<Sample> result = [];
    for (final record in resultQuery) {
      result.add(Sample.fromMap(record));
    }
    return result;
  }
}
