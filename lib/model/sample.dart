import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/segment.dart';
import 'package:khmer_text_vectorization/model/tf_idf.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';

class Sample {
  final int? id;
  final String name;
  final String description;
  final String originalInput;
  final bool? stanceLabel;
  final double quality;
  final DateTime createdAt;

  List<TopicTag>? topicTags;

  Sample({
    this.id,
    required this.name,
    required this.description,
    required this.originalInput,
    this.stanceLabel,
    required this.quality,
    DateTime? createdAt,
    this.topicTags,
  }) : createdAt = createdAt ?? DateTime.now();

  Future<List<Segment>> get segmentedText async {
    if (id != null) {
      final value = await AppDatabase.instance.getSegmentedText(id!);
      return value;
    } else {
      return [];
    }
  }

  Future<Map<int, TfIdf>> get tfIdfVector async {
    if (id != null) {
      return await AppDatabase.instance.getSampleVector(id!);
    } else {
      return {};
    }
  }

  static String get csvHeader =>
      "id,name,stance,quality,original_text,segmented_text,tags,tfidf_json(word:[tf|idf|score])";

  Future<String> toCsvRow(Map<int, Characters> vocabCache) async {
    final segments = await segmentedText;
    final String segmentStrings = segments.map((s) => s.text).join(' ');

    final List<TfIdf> vectorObjects = (await tfIdfVector).values.toList();

    Map<String, List<double>> mathMap = {};
    for (var item in vectorObjects) {
      String word = vocabCache[item.id]?.string ?? "UNKNOWN";
      mathMap[word] = [
        double.parse(item.tf.toStringAsFixed(4)),
        double.parse(item.idf.toStringAsFixed(4)),
        double.parse(item.score.toStringAsFixed(4)),
      ];
    }

    String stance = stanceLabel == null
        ? "No label"
        : (stanceLabel! ? "Positive" : "Negative");

    // Helper to escape double quotes for CSV safety
    String escape(Object? value) {
      final str = value?.toString() ?? "";
      return '"${str.replaceAll('"', '""')}"';
    }

    // Return the joined CSV string row
    return [
      id,
      escape(name),
      stance,
      quality,
      escape(originalInput),
      escape(segmentStrings),
      escape(topicTags?.map((t) => t.tagName).join('|') ?? ''),
      escape(jsonEncode(mathMap)),
    ].join(',');
  }

  // Converts a Database Row (Map) into a Sample Object
  factory Sample.fromMap(
    Map<String, dynamic> map, {
    List<MapEntry<int, String>>? tags,
  }) {
    List<TopicTag> topicTags = [];
    if (tags != null) {
      for (final tag in tags) {
        topicTags.add(TopicTag(id: tag.key, tagName: tag.value));
      }
    }

    bool? stanceLabel;
    if (map["stanceLabel"] != null) {
      stanceLabel = map["stanceLabel"] == 1;
    }

    return Sample(
      id: map['id'] as int,
      name: map['name'].toString(),
      description: (map['description'] ?? '') as String,
      originalInput: map['originalInput'] as String,
      stanceLabel: stanceLabel,
      quality: (map['quality'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      topicTags: topicTags,
    );
  }

  // Converts a Sample Object into a Map for Database Insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'originalInput': originalInput,
      'stanceLabel': stanceLabel != null
          ? stanceLabel!
                ? 1
                : 0
          : null,
      'quality': quality,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
