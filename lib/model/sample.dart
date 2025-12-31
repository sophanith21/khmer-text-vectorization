import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';

class Sample {
  final int? id;
  final String name;
  final String description;
  final String originalInput;
  final int? stanceLabel;
  final double quality;
  final DateTime createdAt;

  final List<TopicTag>? topicTags;

  Future<List<Characters>?> get segmentedText async {
    if (id != null) {
      return await AppDatabase.instance.getSegmentedText(id!);
    } else {
      return null;
    }
  }

  Future<Map<int, double>?> get tfIdfVector async {
    if (id != null) {
      return await AppDatabase.instance.getSampleVector(id!);
    } else {
      return null;
    }
  }

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

    return Sample(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      originalInput: map['originalInput'],
      stanceLabel: map['stanceLabel'],
      quality: (map['quality'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
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
      'stanceLabel': stanceLabel,
      'quality': quality,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
