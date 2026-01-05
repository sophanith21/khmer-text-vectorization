import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';

class QualityAssessService {
  static QualityAssessService instance = QualityAssessService._constructor();
  QualityAssessService._constructor();

  double assessInput(
    List<Characters> segmentedText,
    bool? stanceLabel,
    Set<TopicTag> topicTags,
  ) {
    double score = 0;
    double textLengthMaxScore = 20;
    double noiseMaxScore = 15;
    double labelMaxScore = 40;
    double diverseMaxScore = 25;
    int textLength = segmentedText.length;

    score += _assessTextLength(textLength, textLengthMaxScore);

    score += _assessNoise(segmentedText, noiseMaxScore);

    score += _assessLabel(stanceLabel, topicTags, labelMaxScore);

    score += _assessDiversity(segmentedText, diverseMaxScore);

    return score;
  }

  double _assessTextLength(int textLength, double maxScore) {
    double score = 0;
    if (textLength >= 151) {
      score = 0.75 * maxScore;
    } else if (textLength >= 21) {
      score = maxScore;
    } else if (textLength >= 10) {
      score = 0.5 * maxScore;
    }
    // Smaller than 10, score = 0
    return score;
  }

  double _assessNoise(List<Characters> segmentedText, double maxScore) {
    double score = 0;
    Set<String> noise = {'[ENG]', '[URL]', '[NUM]'};
    int noiseCount = 0;

    if (segmentedText.isEmpty) return score;

    for (final word in segmentedText) {
      if (noise.contains(word.toString())) {
        noiseCount++;
      }
    }

    score += 1.0 - (noiseCount / segmentedText.length) * maxScore;
    return score;
  }

  double _assessLabel(
    bool? stanceLabel,
    Set<TopicTag> topicTags,
    double maxScore,
  ) {
    double score = 0;
    if (stanceLabel != null) {
      score += 0.5 * maxScore;
    }

    if (topicTags.isNotEmpty) {
      score += 0.5 * maxScore;
    }

    return score;
  }

  double _assessDiversity(List<Characters> segmentedText, double maxScore) {
    double score = 0;
    if (segmentedText.isEmpty) return score;
    final Set<Characters> uniqueSegmentedText = segmentedText.toSet();
    score = uniqueSegmentedText.length / segmentedText.length * maxScore;
    return score;
  }
}
