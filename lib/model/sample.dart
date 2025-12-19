import 'dart:convert';

import 'package:characters/characters.dart';

class Sample {
  final String name;
  final String description;
  final List<Characters> segmentedText;
  final List<String> topicLabels;
  late final int stanceLabel;
  late final DateTime createdAt;
  late final double quality;

  Sample({
    required this.name,
    required this.description,
    required this.segmentedText,
    required this.stanceLabel,
    required this.topicLabels,
    required this.quality,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    if (stanceLabel != 0 && stanceLabel != 1) {
      throw ArgumentError("Stance Label can only be 0 and 1");
    }

    if (quality < 0 || quality > 100) {
      throw ArgumentError("Quality must be in range 0 to 100");
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'segmented_text': jsonEncode(
        segmentedText.map((e) => e.toString()).toList(),
      ),
      'topic_labels': jsonEncode(topicLabels),
      'stance_label': stanceLabel,
      'created_at': createdAt.toIso8601String(),
      'quality': quality,
    };
  }

  factory Sample.fromMap(Map<String, dynamic> map) {
    return Sample(
      name: map['name'],
      description: map['description'],
      segmentedText: (jsonDecode(map['segmented_text']) as List)
          .map((e) => (e as String).characters)
          .toList(),
      topicLabels: List<String>.from(jsonDecode(map['topic_labels'])),
      stanceLabel: map['stance_label'],
      quality: (map['quality'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
