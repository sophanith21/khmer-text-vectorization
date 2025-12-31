import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/segment.dart';

class SegmentingService {
  final Set<Characters> dictionary = {};
  static final SegmentingService instance = SegmentingService._constructor();
  SegmentingService._constructor();

  Future<void> _getAllWords() async {
    final db = AppDatabase.instance;

    List<String> list = await db.getAllWords();
    dictionary.addAll(list.map((wordString) => Characters(wordString)).toSet());
  }

  void addNewWord(Characters newWord) {
    dictionary.add(newWord);
    AppDatabase.instance.saveNewWord(newWord.string);
  }

  Future<List<Segment>> segmentRawText(String rawText) async {
    if (dictionary.isEmpty) {
      await _getAllWords();
    }

    final Characters cleanedUpText = Characters(_cleanUpRawText(rawText));

    return _bbm(dictionary: dictionary, rawText: cleanedUpText, lMax: 10);
  }

  List<Segment> _bbm({
    required Set<Characters> dictionary,
    required Characters rawText,
    required int lMax,
  }) {
    // Use a while loop to control the pointer movement
    int pointer = rawText.length;
    List<Segment> result = [];

    // 1. Outer Loop: Moves the segmentation point backward
    while (pointer > 0) {
      bool foundMatch = false;

      // 2. Inner Loop: Searches for the longest match (lMax down to 1)
      for (int l = lMax; l >= 1; l--) {
        // Calculate the start index. Ensure it doesn't go below zero.
        int startPoint = pointer - l;

        // If the potential word is longer than the remaining text, skip and try a shorter length.
        if (startPoint < 0) {
          continue;
        }

        // Extract the substring (grapheme-aware slicing)
        Characters lookUpRange = rawText.getRange(startPoint, pointer);

        // Check the dictionary
        if (dictionary.contains(lookUpRange)) {
          // MATCH FOUND
          result.add(Segment(lookUpRange, true));

          // Move the pointer to the start of the matched word
          pointer = startPoint;
          foundMatch = true;
          break; // Exit the inner loop to restart the outer loop (pointer)
        }
      }

      // 3. Fallback: If inner loop completed without a match (l reached 0)
      if (!foundMatch) {
        // Treat the last unsegmented character as an unknown token
        // This segment is always of length 1 (pointer-1 to pointer)
        Characters unknownToken = rawText.getRange(pointer - 1, pointer);
        final prevResult = result.isNotEmpty ? result.last : null;
        Segment newResult;
        if (prevResult != null && prevResult.isKnown == false) {
          newResult = Segment(unknownToken + prevResult.text, false);
          result.removeLast();
        } else {
          newResult = Segment(unknownToken, false);
        }

        result.add(newResult);

        // Move the pointer back by 1 (the length of the unknown token)
        pointer -= 1;
      }
    }

    // Reverse the list to get the correct reading order
    return result.reversed.toList();
  }

  String _cleanUpRawText(String rawText) {
    const int khmerStart = 0x1780;
    const int khmerEnd = 0x17FF;
    const int symbolStart = 0x19E0;
    const int symbolEnd = 0x19FF;

    final Set<int> autoRemovalCodePoints = {
      '។'.runes.first, // Khmer Sentence End
      '៕'.runes.first, // Khmer Final Mark
      '៘'.runes.first, // Khmer Symbol Used for Continuation
      ' '.runes.first, // Standard Space (U+0020)
    };

    // Keeping [URL] [ENG] [NUM]
    final Set<String> listToKeep = {
      "[",
      "]",
      "E",
      "N",
      "G",
      "U",
      "M",
      "R",
      "L",
    };

    final StringBuffer newString = StringBuffer();

    rawText = maskURL(rawText);
    rawText = maskNumber(rawText);
    rawText = maskLatin(rawText);

    // Initial cleaning of ZWSP
    String zwspCleaned = rawText.replaceAll(RegExp(r'\u200B'), '');

    // Iterate using Characters for correct Khmer grapheme boundaries
    for (String grapheme in zwspCleaned.characters) {
      if (grapheme.isEmpty) continue;

      // Get the code point of the base character (grapheme.runes.first)
      final int codePoint = grapheme.runes.first;

      // Check for inclusion in Khmer ranges
      bool isKhmer =
          (codePoint >= khmerStart && codePoint <= khmerEnd) ||
          (codePoint >= symbolStart && codePoint <= symbolEnd);

      if (!isKhmer) {
        if (listToKeep.contains(grapheme)) {
          isKhmer = true;
        }
      }

      // Check for removal (using Set<int>.contains for speed and correctness)
      final bool shouldRemove = autoRemovalCodePoints.contains(codePoint);

      // If it's a Khmer character AND it is NOT one of the symbols we want to auto-remove
      if (isKhmer && !shouldRemove) {
        newString.write(grapheme);
      }
    }

    // 5. Final space normalization
    return newString.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String maskURL(String rawText) {
    final RegExp urlPattern = RegExp(
      r'\[(?:URL|ENG|NUM)\]|((https?:\/\/|www\.)[^\s]+)',
      caseSensitive: false,
    );
    return rawText.splitMapJoin(
      urlPattern,
      onMatch: (match) {
        if (match.group(1) != null) {
          return '[URL]';
        }

        return match.group(0)!;
      },
      onNonMatch: (nonMatch) => nonMatch,
    );
  }

  String maskNumber(String rawText) {
    final RegExp numPattern = RegExp(
      r'\[(?:URL|ENG|NUM)\]|([0123456789១២៣៤៥៦៧៨៩០]+)',
    );
    return rawText.splitMapJoin(
      numPattern,
      onMatch: (match) {
        if (match.group(1) != null) {
          return '[NUM]';
        }
        return match.group(0)!;
      },
      onNonMatch: (nonMatch) => nonMatch,
    );
  }

  String maskLatin(String rawText) {
    final RegExp latinPattern = RegExp(
      r'\[(?:URL|ENG|NUM)\]|([a-zA-Z\u00C0-\u024F]+)',
      unicode: true,
    );

    return rawText.splitMapJoin(
      latinPattern,
      onMatch: (match) {
        if (match.group(1) != null) {
          return '[ENG]';
        }
        return match.group(0)!;
      },
      onNonMatch: (nonMatch) => nonMatch,
    );
  }
}

// void main() {
//   Set<String> stringTextSet = file.readAsLinesSync().toSet();
//   Set<Characters> wordTextSet = {};
//   for (String word in stringTextSet) {
//     wordTextSet.add(Characters(word));
//   }

//   String rawTextInput =
//       "ឈ្លោះ​គ្នា​ក្នុង​គ្រួសារ ដូច​ស្រាត​កាយា​បង្ហាញ​ញាតិ ឈ្លោះគ្នាក្នុង​សង្គមជាតិ ដូច​លាត​កំណប់​បង្ហាញ​ចោរ ។ ជាប់​ជ្រួល​ច្រវាក់​ភក្ត្រ​ស្រស់ស្រាយ គួរ​ខ្លាច​ខ្លួន​ក្លាយ​ជា​ក្លៀវក្លា វង្វេង​ផ្លូវ​មិន​សួរន​រណា តនឹងបច្ចា​ឥត​អាវុធ ។";

//   Characters testingRawText = Characters(cleanUpRawText(rawTextInput));
//   print("Uncleaned raw text: $rawTextInput");
//   print("Clean raw text: $testingRawText");
//   List<MapEntry<Characters, bool>> result = bbm(
//     dictionary: wordTextSet,
//     rawText: testingRawText,
//     lMax: 10,
//   );
//   for (var word in result) {
//     print(word.key + " ".characters + word.value.toString().characters);
//   }
// }
