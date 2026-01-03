import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/segment.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SamplePersistenceService {
  static SamplePersistenceService instance =
      SamplePersistenceService._constructor();

  static late final SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get needsIDFRefactor =>
      _prefs.getBool('needs_idf_refactor') ?? true;

  static set needsIDFRefactor(bool value) {
    _prefs.setBool('needs_idf_refactor', value);
  }

  SamplePersistenceService._constructor();

  Future<void> refactorGlobalIDF() async {
    needsIDFRefactor = false;
    await AppDatabase.instance.syncGlobalIDF();
  }

  Future<void> deleteSamples(List<int> ids) async {
    await AppDatabase.instance.deleteSamples(ids);
  }

  Future<Sample> saveSample({
    Sample? editSample,
    required String name,
    required String description,
    required String rawText,
    required bool? stanceLabel,
    required double quality,
    required Set<TopicTag> topicTags,
    required List<Segment> segmentedText,
  }) async {
    needsIDFRefactor = true;

    Sample newSample = Sample(
      id: editSample?.id,
      name: name,
      description: description,
      originalInput: rawText,
      quality: quality,
      stanceLabel: stanceLabel,
      topicTags: topicTags.toList(),
    );

    List<Characters> segments = segmentedText.map((e) => e.text).toList();

    await AppDatabase.instance.saveSample(newSample, segments);
    return newSample;
  }
}
