import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/segment.dart';
import 'package:khmer_text_vectorization/model/tf_idf.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  Database? _db;

  // DB Name
  final String _DBname = "kh_vector_db.db";

  // Table Names
  final String _sampleTable = "Sample";
  final String _dictionaryTable = "Dictionary";
  final String _sampleDictionaryTable = "SampleDictionary";
  final String _topicTagsTable = "TopicTags";
  final String _sampleTopicTagsTable = "SampleTopicTags";

  // Column Names
  final String _colId = "id";
  final String _colWord = "word";
  final String _colWeight = "weight";
  final String _colName = "name";
  final String _colDesc = "description";
  final String _colInput = "originalInput";
  final String _colStance = "stanceLabel";
  final String _colQuality = "quality";
  final String _colPosition = "position";
  final String _colTag = "tag";
  final String _colCreatedAt = "created_at";

  static final AppDatabase instance = AppDatabase._constructor();
  AppDatabase._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _getDatabase();
    return _db!;
  }

  Future<void> resetDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, _DBname);

    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    await deleteDatabase(databasePath);
  }

  Future<Database> _getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, _DBname);

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

  Future<void> importDictionary(FilePickerResult result) async {
    final file = File(result.files.single.path!);
    final List<String> lines = await file.readAsLines();

    if (lines.isEmpty) return;

    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      // skipping the header
      for (String word in lines) {
        batch.rawInsert(
          '''
        INSERT OR IGNORE INTO $_dictionaryTable ($_colWord)
        VALUES (?)
      ''',
          [word],
        );
      }

      await batch.commit(noResult: true);
    });
  }

  // --- CRUD OPERATIONS ---

  // Saves a complete Sample with ordered segments and topic tags or edit the
  // sample if it has an id
  Future<void> saveSample(Sample sample, List<Characters> segments) async {
    final db = await database;

    await db.transaction((txn) async {
      int sampleId;

      if (sample.id != null) {
        // Update the sample
        sampleId = sample.id!;

        final updatedData = sample.toMap();
        updatedData.remove('id');

        await txn.update(
          _sampleTable,
          updatedData,
          where: '$_colId = ?',
          whereArgs: [sampleId],
        );

        // Remove old word positions and old tags linked to this sample
        await txn.delete(
          _sampleDictionaryTable,
          where: 'sample_id = ?',
          whereArgs: [sampleId],
        );
        await txn.delete(
          _sampleTopicTagsTable,
          where: 'sample_id = ?',
          whereArgs: [sampleId],
        );
      } else {
        print("PATH TAKEN: INSERT");
        // Add new sample
        sampleId = await txn.insert(_sampleTable, sample.toMap());
      }

      final List<String> uniqueWords = segments
          .map((e) => e.string)
          .toSet()
          .toList();

      final List<Map<String, dynamic>> dictionaryRows = await txn.query(
        _dictionaryTable,
        columns: [_colId, _colWord],
        where:
            '$_colWord IN (${List.filled(uniqueWords.length, '?').join(',')})',
        whereArgs: uniqueWords,
      );

      // Map: {"apple": 1, "banana": 2}
      final Map<String, int> wordToIdMap = {
        for (var row in dictionaryRows)
          row[_colWord] as String: row[_colId] as int,
      };

      // Re-insert Segments or new segments
      final wordBatch = txn.batch();
      for (int i = 0; i < segments.length; i++) {
        String word = segments[i].string;
        if (wordToIdMap[word] != null) {
          int wordId = wordToIdMap[word]!;
          wordBatch.insert(_sampleDictionaryTable, {
            'sample_id': sampleId,
            'dictionary_id': wordId,
            _colPosition: i,
          });
        }
      }
      await wordBatch.commit(noResult: true);

      // Re-insert Tags or new tags
      if (sample.topicTags != null) {
        final tagBatch = txn.batch();
        for (var tag in sample.topicTags!) {
          if (tag.id != null) {
            int tagId = tag.id!;
            tagBatch.insert(_sampleTopicTagsTable, {
              'sample_id': sampleId,
              'tag_id': tagId,
            });
          }
        }
        await tagBatch.commit(noResult: true);
      }
    });
  }

  Future<int> saveNewTag(TopicTag newTag) async {
    final db = await database;

    return await db.transaction((txn) async {
      return await db.insert(
        _topicTagsTable,
        newTag.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });
  }

  Future<int> saveNewWord(String newWord) async {
    final db = await database;

    return await db.transaction((txn) async {
      return await txn.insert(_dictionaryTable, {
        _colWord: newWord,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    });
  }

  // Loads all dictionary words into memory for the BMM algorithm
  Future<Map<Characters, int>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> queryResult = await db.query(
      _dictionaryTable,
      columns: [_colWord, _colId],
    );

    if (queryResult.isNotEmpty) {
      return {
        for (var row in queryResult)
          row[_colWord].toString().characters: row[_colId] as int,
      };
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
    final List<Map<String, dynamic>> secondQuery = await db.query(
      _dictionaryTable,
      columns: [_colWord, _colId],
    );
    return {
      for (var row in secondQuery)
        row[_colWord].toString().characters: row[_colId] as int,
    };
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

  Future<void> deleteSamples(List<int> sampleIds) async {
    if (sampleIds.isEmpty) {
      return;
    }
    final db = await database;

    final placeholders = List.filled(sampleIds.length, '?').join(', ');
    await db.transaction((txn) async {
      await txn.delete(
        _sampleTable,
        where: 'id IN ($placeholders)',
        whereArgs: sampleIds.toList(),
      );

      await txn.delete(
        _sampleDictionaryTable,
        where: 'sample_id IN ($placeholders)',
        whereArgs: sampleIds.toList(),
      );

      await txn.delete(
        _sampleTopicTagsTable,
        where: 'sample_id IN ($placeholders)',
        whereArgs: sampleIds.toList(),
      );
    });
  }

  Future<void> updateWord(MapEntry<Characters, int> newWord) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        _dictionaryTable,
        {_colWord: newWord.key.string},
        where: "$_colId = ?",
        whereArgs: [newWord.value],
      );
    });
  }

  Future<void> deleteWord(int id) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.rawDelete(
        '''
    DELETE FROM $_dictionaryTable
    WHERE $_colId = ?
    ''',
        [id],
      );
    });
  }

  Future<Set<int>> getUsedWord() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT DISTINCT dictionary_id as unique_words FROM $_sampleDictionaryTable
''');

    return {for (final word in result) word["unique_words"] as int};
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

  Future<List<Segment>> getSegmentedText(int sampleId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT d.$_colWord as segmented_text, d.$_colId as dictionary_id FROM $_sampleDictionaryTable sd
      JOIN $_dictionaryTable d ON sd.dictionary_id = d.$_colId
      WHERE sd.sample_id = ?
      ORDER By sd.position ASC
      ''',
      [sampleId],
    );

    List<Segment> segmentedText = [];
    for (final word in result) {
      segmentedText.add(
        Segment(
          word["dictionary_id"] as int,
          word["segmented_text"].toString().characters,
          true,
        ),
      );
    }

    return segmentedText;
  }

  /// Calculates the TF-IDF vector on-the-fly for a specific sample
  Future<Map<int, TfIdf>> getSampleVector(int sampleId) async {
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

    Map<int, TfIdf> vector = {};
    for (var row in rows) {
      double tf = (row['word_count'] as int) / totalWords;
      double idf = (row[_colWeight] as num).toDouble();
      vector[row['dictionary_id'] as int] = TfIdf(
        row['dictionary_id'] as int,
        tf,
        idf,
        tf * idf,
      );
    }
    return vector;
  }

  Future<String> generateVocabularyCSV() async {
    final db = await database;

    // This pulls the latest values directly from your Dictionary table
    final List<Map<String, dynamic>> result = await db.query(
      'Dictionary',
      columns: [_colId, _colWord, _colWeight], // Your existing IDF column
    );

    StringBuffer csv = StringBuffer();
    csv.writeln("$_colId,$_colWord,$_colWeight");

    for (var row in result) {
      String word = row[_colWord].toString().replaceAll('"', '""');
      double idfValue = (row[_colWeight] as num).toDouble();

      csv.writeln("${row[_colId]},\"$word\",${idfValue.toStringAsFixed(6)}");
    }
    return csv.toString();
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

  Future<void> syncGlobalIDF() async {
    final db = await database;

    // Retrieve the total number of documents (N) in the collection
    final int totalDocuments =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_sampleTable'),
        ) ??
        1;

    // Fetch the Document Frequency (DF) for every term associated with at least one sample
    final List<Map<String, dynamic>> dfResults = await db.rawQuery('''
      SELECT dictionary_id, COUNT(DISTINCT sample_id) as df
      FROM $_sampleDictionaryTable
      GROUP BY dictionary_id
      ''');

    final batch = db.batch();

    for (final row in dfResults) {
      final int dictionaryId = row['dictionary_id'] as int;
      final int documentFrequency = row['df'] as int;

      /**
       * IDF Formula: log(Total Documents / Documents containing Term)
       * This measures how important a term is within the entire corpus.
       */
      final double idfScore = log(totalDocuments / documentFrequency);

      batch.update(
        _dictionaryTable,
        {_colWeight: idfScore},
        where: '$_colId = ?',
        whereArgs: [dictionaryId],
      );
    }

    // Execute all queued updates in the batch
    await batch.commit(noResult: true);
  }
}
