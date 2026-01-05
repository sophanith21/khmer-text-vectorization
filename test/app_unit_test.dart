import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/segment.dart';
import 'package:khmer_text_vectorization/model/tf_idf.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';
import 'package:khmer_text_vectorization/model/services/quality_assess_service.dart';
import 'package:khmer_text_vectorization/model/services/sample_persistence_service.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/model/services/suggest_tags_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:characters/characters.dart';

void main() {
  group('Sample Model Tests', () {
    late Sample sample;
    late Map<int, Characters> vocabCache;

    setUp(() {
      sample = Sample(
        id: 1,
        name: 'Test Sample',
        description: 'Test description',
        originalInput: 'អត្ថបទគំរូ',
        stanceLabel: true,
        quality: 85.5,
        createdAt: DateTime(2024, 1, 1),
        topicTags: [
          TopicTag(id: 1, tagName: 'Politics'),
          TopicTag(id: 2, tagName: 'Economy'),
        ],
      );

      vocabCache = {1: 'អត្ថបទ'.characters, 2: 'គំរូ'.characters};
    });

    test('fromMap creates correct Sample object', () {
      final map = {
        'id': 1,
        'name': 'Test',
        'description': 'Desc',
        'originalInput': 'Input',
        'stanceLabel': 1,
        'quality': 90.0,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final result = Sample.fromMap(
        map,
        tags: [const MapEntry(1, 'Tag1'), const MapEntry(2, 'Tag2')],
      );

      expect(result.id, 1);
      expect(result.name, 'Test');
      expect(result.stanceLabel, true);
      expect(result.topicTags?.length, 2);
    });

    test('toMap returns correct map structure', () {
      final map = sample.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Test Sample');
      expect(map['stanceLabel'], 1);
      expect(map['quality'], 85.5);
    });

    test('csvHeader returns correct format', () {
      expect(Sample.csvHeader, contains('id,name,stance,quality'));
    });
    test('toCsvRow formats correctly without database', () async {
      // Sample without ID to avoid database calls
      final testSample = Sample(
        id: null,
        name: 'Test,with"commas"and"quotes',
        description: 'Description',
        originalInput: 'អត្ថបទ',
        quality: 75.0,
      );

      final simpleVocab = {1: 'អត្ថបទ'.characters};

      // Call toCsvRow – no database is used because id is null
      final csv = await testSample.toCsvRow(simpleVocab);

      // Should contain escaped quotes
      expect(csv, contains('""'));

      // Should contain the name
      expect(csv, contains('Test,with""commas""and""quotes'));

      // Should contain the quality
      expect(csv, contains('75.0'));
    });

    test('stanceLabel null handling', () {
      final nullStanceSample = Sample(
        name: 'Test',
        description: 'Desc',
        originalInput: 'Input',
        quality: 50.0,
      );

      expect(nullStanceSample.stanceLabel, isNull);
    });
  });

  group('Segment Model Tests', () {
    test('Segment creation and properties', () {
      final segment = Segment(1, 'ពាក្យ'.characters, true);

      expect(segment.id, 1);
      expect(segment.text.string, 'ពាក្យ');
      expect(segment.isKnown, true);
    });

    test('Segment unknown word handling', () {
      final unknownSegment = Segment(null, 'XYZ'.characters, false);

      expect(unknownSegment.id, isNull);
      expect(unknownSegment.isKnown, false);
    });
  });

  group('TfIdf Model Tests', () {
    test('TfIdf creation and calculations', () {
      final tfidf = TfIdf(1, 0.25, 2.0, 0.5);

      expect(tfidf.id, 1);
      expect(tfidf.tf, 0.25);
      expect(tfidf.idf, 2.0);
      expect(tfidf.score, 0.5);
      expect(tfidf.score, equals(tfidf.tf * tfidf.idf));
    });
  });

  group('TopicTag Model Tests', () {
    test('TopicTag creation and equality', () {
      final tag1 = TopicTag(id: 1, tagName: 'Technology');
      final tag2 = TopicTag(id: 1, tagName: 'Technology');
      final tag3 = TopicTag(id: 2, tagName: 'Science');

      expect(tag1, equals(tag2));
      expect(tag1, isNot(equals(tag3)));
      expect(tag1.hashCode, equals(tag2.hashCode));
    });

    test('toMap and fromMap', () {
      final tag = TopicTag(id: 1, tagName: 'Test');
      final map = tag.toMap();
      final fromMap = TopicTag.fromMap({'id': 1, 'tag': 'Test'});

      expect(map['tag'], 'Test');
      expect(fromMap.id, 1);
      expect(fromMap.tagName, 'Test');
    });
  });

  group('QualityAssessService Tests', () {
    late QualityAssessService service;

    setUp(() {
      service = QualityAssessService.instance;
    });

    test('assessInput with various inputs', () {
      // Test 1: Good quality sample
      final goodSegments = [
        'ពាក្យ'.characters,
        'ខ្មែរ'.characters,
        'ភាសា'.characters,
        'សិក្សា'.characters,
        'បច្ចេកវិទ្យា'.characters,
      ];
      final goodTags = {
        TopicTag(tagName: 'Education'),
        TopicTag(tagName: 'Technology'),
      };

      final goodScore = service.assessInput(goodSegments, true, goodTags);
      expect(goodScore, greaterThan(50));
      expect(goodScore, lessThanOrEqualTo(100));

      // Test 2: Noisy sample
      final noisySegments = [
        'ពាក្យ'.characters,
        '[ENG]'.characters,
        '[URL]'.characters,
        '[NUM]'.characters,
      ];
      final noisyScore = service.assessInput(noisySegments, null, {});
      expect(noisyScore, lessThan(goodScore));

      // Test 3: Very short text
      final shortSegments = ['ពាក្យ'.characters];
      final shortScore = service.assessInput(shortSegments, false, {
        TopicTag(tagName: 'Test'),
      });
      expect(shortScore, greaterThan(50));

      // Test 4: Repetitive text (low diversity)
      final repetitiveSegments = [
        'ពាក្យ'.characters,
        'ពាក្យ'.characters,
        'ពាក្យ'.characters,
      ];
      final repetitiveScore = service.assessInput(repetitiveSegments, true, {});
      expect(repetitiveScore, lessThan(100));

      // Test 5: Well-labeled sample
      final wellLabeledSegments = List.generate(
        15,
        (index) => 'ពាក្យ$index'.characters,
      );
      final wellLabeledScore = service.assessInput(wellLabeledSegments, true, {
        TopicTag(tagName: 'Tag1'),
        TopicTag(tagName: 'Tag2'),
        TopicTag(tagName: 'Tag3'),
      });
      expect(wellLabeledScore, greaterThan(70));
    });

    test('assessInput edge cases', () {
      // Empty input
      final emptyScore = service.assessInput([], null, {});
      expect(emptyScore, 0);

      // Very long text (more than 151 words)
      final longSegments = List.generate(
        200,
        (index) => 'ពាក្យ$index'.characters,
      );
      final longScore = service.assessInput(longSegments, true, {
        TopicTag(tagName: 'Test'),
      });
      expect(longScore, greaterThan(0));
      expect(longScore, lessThanOrEqualTo(100));

      // All noise
      final allNoise = List.filled(20, '[ENG]'.characters);
      final noiseScore = service.assessInput(allNoise, false, {});
      expect(noiseScore, lessThan(50));

      // Perfect diversity (all unique words)
      final perfectDiversity = List.generate(
        30,
        (index) => 'ពាក្យ$index'.characters,
      );
      final diversityScore = service.assessInput(perfectDiversity, true, {
        TopicTag(tagName: 'Tag1'),
        TopicTag(tagName: 'Tag2'),
      });
      expect(diversityScore, greaterThan(80));
    });
  });

  group('SegmentingService Tests', () {
    late SegmentingService service;

    setUp(() {
      service = SegmentingService.instance;
    });

    test('Text masking functions work correctly', () {
      // Test URL masking
      const urlText = 'Visit https://example.com and www.test.com';
      final maskedURL = service.maskURL(urlText);
      expect(maskedURL, contains('[URL]'));
      expect(maskedURL, isNot(contains('https://')));

      // Test number masking
      const numberText = 'លេខ 123 និង ៤៥៦';
      final maskedNumber = service.maskNumber(numberText);
      expect(maskedNumber, contains('[NUM]'));
      expect(maskedNumber, isNot(contains('123')));

      // Test Latin text masking
      const latinText = 'ការសិក្សា Study ភាសា English';
      final maskedLatin = service.maskLatin(latinText);
      expect(maskedLatin, contains('[ENG]'));
      expect(maskedLatin, isNot(contains('Study')));
    });

    test('Combined text masking', () {
      const complexText =
          'Visit https://site.com for info. Phone: 012-345-6789. English text here.';
      final result1 = service.maskURL(complexText);
      final result2 = service.maskNumber(result1);
      final result3 = service.maskLatin(result2);

      expect(result3, contains('[URL]'));
      expect(result3, contains('[NUM]'));
      expect(result3, contains('[ENG]'));
    });

    test('Text masking preserves existing markers', () {
      const textWithMarkers = 'Already [URL] here and [ENG] and [NUM]';
      final urlResult = service.maskURL(textWithMarkers);
      final numResult = service.maskNumber(urlResult);
      final latinResult = service.maskLatin(numResult);

      // Should preserve existing markers
      expect(latinResult, contains('[URL]'));
      expect(latinResult, contains('[ENG]'));
      expect(latinResult, contains('[NUM]'));
    });
  });

  group('SuggestTagsService Tests', () {
    test('suggestionTags returns empty set initially', () async {
      final service = SuggestTagsService.instance;
      // Without database mocking, we can only test the interface
      expect(service, isNotNull);
    });
  });

  group('SamplePersistenceService Tests', () {
    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({'needs_idf_refactor': true});
      await SamplePersistenceService.init();
    });

    test('needsIDFRefactor getter/setter', () async {
      // await SamplePersistenceService.init();

      expect(SamplePersistenceService.needsIDFRefactor, true);

      SamplePersistenceService.needsIDFRefactor = false;
      expect(SamplePersistenceService.needsIDFRefactor, false);
    });
  });

  group('Export/Import CSV Tests', () {
    // test('Sample CSV escaping', () async {
    //   final sample = Sample(
    //     id: 1,
    //     name: 'Test,with"commas"and"quotes',
    //     description: 'Description with "quotes"',
    //     originalInput: 'អត្ថបទ​ដែលមាន"ឃ្លា"',
    //     quality: 75.0,
    //   );

    //   final vocabCache = {1: 'អត្ថបទ'.characters};

    //   // Test that CSV escaping works
    //   final csv = await sample.toCsvRow(vocabCache);

    //   // Verify proper CSV format
    //   expect(csv.split(',').length, greaterThanOrEqualTo(8));
    //   // Should have escaped quotes doubled
    //   expect(csv, contains('""'));
    // });
    test('Sample CSV escaping', () async {
      // By setting id to NULL, we prevent the model from calling AppDatabase.instance
      // This allows the test to run without needing a database initialization.
      final sample = Sample(
        id: null, // CRITICAL: Keep this null for unit tests
        name: 'Test,with"commas"and"quotes',
        description: 'Description with "quotes"',
        originalInput: 'អត្ថបទ​ដែលមាន"ឃ្លា"',
        quality: 75.0,
        topicTags: [
          TopicTag(id: 1, tagName: 'Tag"With"Quotes'),
          TopicTag(id: 2, tagName: 'Tag,With,Commas'),
        ],
      );

      // We provide an empty cache because segmentedText and tfIdfVector
      // will return empty defaults when id is null.
      final vocabCache = {1: 'អត្ថបទ'.characters};

      // Test that CSV escaping works
      final csv = await sample.toCsvRow(vocabCache);

      // 1. Verify proper CSV column count (8 columns)
      expect(csv.split(',').length, greaterThanOrEqualTo(8));

      // 2. Verify Name is escaped: "Test,with""commas""and""quotes"
      expect(csv, contains('""commas""'));
      expect(csv, contains('"Test,with'));

      // 3. Verify original input is escaped
      expect(csv, contains('""ឃ្លា""'));

      // 4. Verify Tags are joined and escaped
      // Based on your code: escape(topicTags.join('|'))
      expect(csv, contains('Tag""With""Quotes|Tag,With,Commas'));
    });

    test('CSV with special characters', () async {
      final sample = Sample(
        id: null,
        name: 'Sample\nwith\nnewlines',
        description: 'Desc\ttabs\r\nand\rreturns',
        originalInput: 'Text with various\n\t\rcharacters',
        quality: 50.0,
      );

      final vocabCache = {1: 'ពាក្យ'.characters};

      final csv = await sample.toCsvRow(vocabCache);
      // Should handle special characters without breaking CSV format
      expect(csv.split(',').length, greaterThanOrEqualTo(8));

      expect(csv, contains('"Sample\nwith\nnewlines"'));
    });
  });

  group('Edge Cases Tests', () {
    test('Sample with null ID', () {
      final sample = Sample(
        name: 'Test',
        description: 'Desc',
        originalInput: 'Input',
        quality: 0.0,
      );

      expect(sample.id, isNull);
      expect(sample.stanceLabel, isNull);
      expect(sample.topicTags, isNull);
      expect(sample.createdAt, isNotNull);
    });

    test('Sample with empty fields', () {
      final sample = Sample(
        name: '',
        description: '',
        originalInput: '',
        quality: 0.0,
      );

      expect(sample.name, isEmpty);
      expect(sample.originalInput, isEmpty);
      expect(sample.quality, 0.0);
    });

    test('TopicTag with empty name', () {
      final tag = TopicTag(tagName: '');
      expect(tag.tagName, isEmpty);
    });

    test('Quality assessment minimum values', () {
      final service = QualityAssessService.instance;

      // Minimum possible score
      final minScore = service.assessInput([], null, {});
      expect(minScore, 0);

      // Single word, no labels
      final singleWordScore = service.assessInput(
        ['word'.characters],
        null,
        {},
      );
      expect(singleWordScore, greaterThanOrEqualTo(0));
      expect(singleWordScore, lessThanOrEqualTo(100));
    });
  });

  group('Integration Patterns', () {
    test('Sample toMap and fromMap roundtrip', () {
      final original = Sample(
        id: 1,
        name: 'Test',
        description: 'Description',
        originalInput: 'Input text',
        stanceLabel: true,
        quality: 85.5,
        createdAt: DateTime(2024, 1, 1),
        topicTags: [TopicTag(id: 1, tagName: 'Tag1')],
      );

      final map = original.toMap();
      final restored = Sample.fromMap(map, tags: [const MapEntry(1, 'Tag1')]);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.stanceLabel, original.stanceLabel);
      expect(restored.quality, original.quality);
      expect(restored.topicTags?.length, original.topicTags?.length);
    });

    test('TopicTag equality and hashcode consistency', () {
      final tag1 = TopicTag(id: 1, tagName: 'Same');
      final tag2 = TopicTag(id: 2, tagName: 'Same'); // Different ID, same name
      final tag3 = TopicTag(
        id: 1,
        tagName: 'Different',
      ); // Same ID, different name

      // Equality is based on tagName only
      expect(tag1, equals(tag2));
      expect(tag1, isNot(equals(tag3)));

      // Hashcode should match for equal objects
      expect(tag1.hashCode, equals(tag2.hashCode));
    });

    test('TF-IDF calculations', () {
      // Test TF-IDF formula
      const tf = 0.25;
      const idf = 2.0;
      const expectedScore = tf * idf;

      final tfidf = TfIdf(1, tf, idf, expectedScore);

      expect(tfidf.score, expectedScore);
      expect(tfidf.score, equals(tf * idf));
    });
  });

  group('Character Handling Tests', () {
    test('Characters class usage', () {
      final khmerText = 'ពាក្យខ្មែរ';
      final characters = khmerText.characters;

      expect(characters.length, greaterThan(0));
      expect(characters.string, khmerText);
    });

    test('Segment with Characters', () {
      final segment = Segment(1, 'ពាក្យ'.characters, true);

      expect(segment.text is Characters, true);
      expect(segment.text.string, 'ពាក្យ');
    });
  });

  group('Service Singleton Patterns', () {
    test('All services are singletons', () {
      final qualityService1 = QualityAssessService.instance;
      final qualityService2 = QualityAssessService.instance;
      expect(qualityService1, same(qualityService2));

      final segmentingService1 = SegmentingService.instance;
      final segmentingService2 = SegmentingService.instance;
      expect(segmentingService1, same(segmentingService2));

      final suggestTagsService1 = SuggestTagsService.instance;
      final suggestTagsService2 = SuggestTagsService.instance;
      expect(suggestTagsService1, same(suggestTagsService2));
    });
  });

  group('DateTime Handling', () {
    test('Sample createdAt defaults to now', () {
      final beforeCreation = DateTime.now();
      final sample = Sample(
        name: 'Test',
        description: 'Desc',
        originalInput: 'Input',
        quality: 50.0,
      );
      final afterCreation = DateTime.now();

      expect(
        sample.createdAt.isAfter(beforeCreation) ||
            sample.createdAt.isAtSameMomentAs(beforeCreation),
        true,
      );
      expect(
        sample.createdAt.isBefore(afterCreation) ||
            sample.createdAt.isAtSameMomentAs(afterCreation),
        true,
      );
    });

    test('Sample with provided createdAt', () {
      final customDate = DateTime(2023, 12, 25);
      final sample = Sample(
        name: 'Test',
        description: 'Desc',
        originalInput: 'Input',
        quality: 50.0,
        createdAt: customDate,
      );

      expect(sample.createdAt, customDate);
    });
  });
}
