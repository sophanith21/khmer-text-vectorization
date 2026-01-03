import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/services/sample_persistence_service.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportImportService {
  static Future<void> resetDictionary() async {
    await AppDatabase.instance.resetDatabase();
  }

  static Future<void> importDictionary(FilePickerResult result) async {
    await AppDatabase.instance.importDictionary(result);
  }

  static Future<void> exportFullDataset(
    List<Sample> samples,
    Map<int, Characters> dictionary,
  ) async {
    await SamplePersistenceService.instance.refactorGlobalIDF();
    try {
      final directory = await getTemporaryDirectory();
      final String timestamp = DateTime.now()
          .toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '-')
          .replaceAll('T', '_');
      // --- FILE 1: SAMPLES ---

      StringBuffer sampleBuffer = StringBuffer();
      sampleBuffer.writeln(Sample.csvHeader);
      for (var s in samples) {
        sampleBuffer.writeln(await s.toCsvRow(dictionary));
      }

      final File sampleFile = File(
        p.join(directory.path, "samples_$timestamp.csv"),
      );
      await sampleFile.writeAsBytes(utf8.encode(sampleBuffer.toString()));

      // --- FILE 2: VOCABULARY (Global IDF) ---
      String vocabCsvString = await AppDatabase.instance
          .generateVocabularyCSV();

      final File vocabFile = File(
        p.join(directory.path, "vocabulary_$timestamp.csv"),
      );
      await vocabFile.writeAsBytes(utf8.encode(vocabCsvString));

      // --- SHARE BOTH ---
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(sampleFile.path, mimeType: 'text/csv'),
            XFile(vocabFile.path, mimeType: 'text/csv'),
          ],
          text: 'Khmer NLP Dataset: Samples and Global Vocabulary Weights',
        ),
      );
    } catch (e) {
      print("Export Error: $e");
    }
  }

  static Future<void> exportDictionary() async {
    try {
      final directory = await getTemporaryDirectory();
      final String timestamp = DateTime.now()
          .toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '-')
          .replaceAll('T', '_');

      // --- Dictionary ---
      String dictionary = SegmentingService.instance.dictionary.keys.join("\n");

      final File dictionaryFile = File(
        p.join(directory.path, "dictionary_$timestamp.txt"),
      );
      await dictionaryFile.writeAsBytes(utf8.encode(dictionary));

      // --- SHARE BOTH ---
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(dictionaryFile.path, mimeType: 'text/plain')],
          text: 'Khmer NLP Dataset: Dictionary / Global Vocabulary Weights',
        ),
      );
    } catch (e) {
      print("Export Error: $e");
    }
  }
}
