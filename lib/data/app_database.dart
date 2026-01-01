import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  Database? _db;

  // Table Names
  static const String _sampleTable = "Sample";
  static const String _dictionaryTable = "Dictionary";
  static const String _sampleDictionaryTable = "SampleDictionary";
  static const String _topicTagsTable = "TopicTags";
  static const String _sampleTopicTagsTable = "SampleTopicTags";

  // Column Names
  static const String _colId = "id";
  static const String _colWord = "word";
  static const String _colWeight = "weight";
  static const String _colName = "name";
  static const String _colDesc = "description";
  static const String _colInput = "originalInput";
  static const String _colStance = "stanceLabel";
  static const String _colQuality = "quality";
  static const String _colPosition = "position";
  static const String _colTag = "tag";
  static const String _colCreatedAt = "created_at";

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

    await deleteDatabase(databasePath);

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        // 1. Core Sample Table
        await db.execute('''
          CREATE TABLE $_sampleTable (
            $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colName TEXT NOT NULL,
            $_colDesc TEXT,
            $_colInput TEXT NOT NULL,
            $_colStance INTEGER, 
            $_colQuality REAL NOT NULL DEFAULT 0.0,
            $_colCreatedAt TEXT
          )
        ''');

        // 2. Vocabulary Dictionary
        await db.execute('''
          CREATE TABLE $_dictionaryTable (
            $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colWord TEXT NOT NULL UNIQUE,
            $_colWeight REAL DEFAULT 1.0
          )
        ''');

        // 3. Sequential Bridge (Sample <-> Dictionary)
        await db.execute('''
          CREATE TABLE $_sampleDictionaryTable (
            sample_id INTEGER,
            dictionary_id INTEGER,
            $_colPosition INTEGER, 
            FOREIGN KEY(sample_id) REFERENCES $_sampleTable($_colId),
            FOREIGN KEY(dictionary_id) REFERENCES $_dictionaryTable($_colId),
            PRIMARY KEY(sample_id, $_colPosition)
          )
        ''');

        // 4. Topic Tags Master
        await db.execute('''
          CREATE TABLE $_topicTagsTable (
            $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colTag TEXT NOT NULL UNIQUE
          )
        ''');

        // 5. Sample <-> Tags Bridge
        await db.execute('''
          CREATE TABLE $_sampleTopicTagsTable (
            sample_id INTEGER,
            tag_id INTEGER,
            FOREIGN KEY(sample_id) REFERENCES $_sampleTable($_colId),
            FOREIGN KEY(tag_id) REFERENCES $_topicTagsTable($_colId),
            PRIMARY KEY(sample_id, tag_id)
          )
        ''');
      },
    );
  }

  // --- CRUD OPERATIONS ---

  // Saves a complete Sample with ordered segments and topic tags
  Future<void> saveFullContribution(
    Sample sample,
    List<Characters> segments,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. Insert Sample Header
      int sampleId = await txn.insert(_sampleTable, sample.toMap());

      // 2. Process Segments Sequentially
      for (int i = 0; i < segments.length; i++) {
        String word = segments[i].string;

        var res = await txn.query(
          _dictionaryTable,
          columns: [_colId],
          where: '$_colWord = ?',
          whereArgs: [word],
        );
        int wordId = res.first[_colId] as int;

        // Save position for reconstruction
        await txn.insert(_sampleDictionaryTable, {
          'sample_id': sampleId,
          'dictionary_id': wordId,
          _colPosition: i,
        });
      }
      if (sample.topicTags != null) {
        for (var tag in sample.topicTags!) {
          var res = await txn.query(
            _topicTagsTable,
            columns: [_colId],
            where: '$_colTag = ?',
            whereArgs: [tag.tagName],
          );
          int tagId = res.first[_colId] as int;

          await txn.insert(_sampleTopicTagsTable, {
            'sample_id': sampleId,
            'tag_id': tagId,
          });
        }
        // 3. Link Topic Tags
      }
    });
  }

  Future<int> saveNewTag(TopicTag newTag) async {
    final db = await database;

    return await db.insert(
      _topicTagsTable,
      newTag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> saveNewWord(String newWord) async {
    final db = await database;

    await db.insert(_dictionaryTable, {_colWord: newWord});
  }

  // Loads all dictionary words into memory for the BMM algorithm
  Future<List<String>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> queryResult = await db.query(
      _dictionaryTable,
      columns: [_colWord],
    );

    if (queryResult.isNotEmpty) {
      return queryResult.map((row) => row[_colWord].toString()).toList();
    }

    // Initialize from assets if DB is fresh
    List<String> assetWords = await _readLinesFromAssets(
      "assets/factory_dictionary.txt",
    );
    final batch = db.batch();
    for (final word in assetWords) {
      batch.insert(_dictionaryTable, {
        _colWord: word,
        _colWeight: 1.0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit();
    return assetWords;
  }

  Future<List<TopicTag>> getAllTags() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM $_topicTagsTable
      ''');

    List<TopicTag> topicTags = [];
    for (final tag in result) {
      topicTags.add(TopicTag.fromMap(tag));
    }
    return topicTags;
  }

  Future<List<Sample>> getAllSamples() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM $_sampleTable
      ''');

    List<Sample> samples = result.map((e) => Sample.fromMap(e)).toList();

    final topicTagsResult = await db.rawQuery('''
        SELECT tt.$_colTag as tag, st.sample_id as sampleId, st.tag_id as id FROM $_sampleTopicTagsTable st
        JOIN $_topicTagsTable tt ON st.tag_id = tt.$_colId
        ''');

    for (final Sample sample in samples) {
      final topicTagsMap = topicTagsResult
          .where((e) => e["sampleId"] == sample.id!)
          .toList();
      sample.topicTags = topicTagsMap.map((e) => TopicTag.fromMap(e)).toList();
    }
    return samples;
  }

  Future<List<Characters>> getSegmentedText(int sampleId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT d.$_colWord as segmented_text FROM $_sampleDictionaryTable sd
      JOIN $_dictionaryTable d ON sd.dictionary_id = d.$_colId
      WHERE sd.sample_id = ?
      ORDER By sd.position ASC
      ''',
      [sampleId],
    );

    List<Characters> segmentedText = [];
    for (final word in result) {
      segmentedText.add(word["segmented_text"].characters);
    }
    return segmentedText;
  }

  /// Calculates the TF-IDF vector on-the-fly for a specific sample
  Future<Map<int, double>> getSampleVector(int sampleId) async {
    final db = await database;

    // Aggregate counts from the sequential table
    final List<Map<String, dynamic>> rows = await db.rawQuery(
      '''
      SELECT sd.dictionary_id, COUNT(*) as word_count, d.$_colWeight
      FROM $_sampleDictionaryTable sd
      JOIN $_dictionaryTable d ON sd.dictionary_id = d.$_colId
      WHERE sd.sample_id = ?
      GROUP BY sd.dictionary_id
    ''',
      [sampleId],
    );

    int totalWords = 0;
    for (var row in rows) {
      totalWords += (row['word_count'] as int);
    }

    Map<int, double> vector = {};
    for (var row in rows) {
      double tf = (row['word_count'] as int) / totalWords;
      double idf = (row[_colWeight] as num).toDouble();
      vector[row['dictionary_id'] as int] = tf * idf;
    }
    return vector;
  }

  // --- HELPERS ---
  Future<List<String>> _readLinesFromAssets(String path) async {
    final data = await rootBundle.load(path);
    return utf8
        .decode(data.buffer.asUint8List())
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }
}
