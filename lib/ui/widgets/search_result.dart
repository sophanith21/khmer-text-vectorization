import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'vectorized_text_box.dart';

class Searchresult extends StatelessWidget {
  const Searchresult({
    super.key,
    required this.dictionaryTexts,
    required this.searchQuery,
    required this.allSamples,
    this.topicSort = "",
    required this.selectedIndex,
    required this.onView,
    required this.onSelected,
    this.onSelectAll,
  });

  final Map<Characters, int> dictionaryTexts;
  final List<Sample> allSamples;
  final String searchQuery;
  final String topicSort;

  final Set<int>? selectedIndex;
  final ValueChanged<Sample> onView;
  final ValueChanged<Sample> onSelected;
  final ValueChanged<List<Sample>>? onSelectAll;

  bool get isSelectionMode => selectedIndex!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    List<Sample> filterSamples = allSamples
        .where(
          (item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    if (topicSort.isNotEmpty && topicSort != "All" && topicSort != "") {
      filterSamples = filterSamples
          .where(
            (item) => (item.topicTags ?? []).any(
              (t) => t.tagName.toLowerCase() == topicSort.toLowerCase(),
            ),
          )
          .toList();
    }

    Map<Characters, int> filterDictionary = Map.fromEntries(
      dictionaryTexts.entries.where(
        (item) => item.key.toLowerCase().contains(searchQuery.toLowerCase()),
      ),
    );

    final bool showDictionary = dictionaryTexts.isNotEmpty;
    final listToShow = showDictionary ? filterDictionary : filterSamples;
    if ((listToShow is List && listToShow.isEmpty) ||
        listToShow is Map && listToShow.isEmpty) {
      return Expanded(
        child: Center(
          child: const Text(
            "No items found",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 0,
                  color: Color(0xFFE2C8A3),
                  offset: Offset(3, 3),
                ),
              ],
            ),
          ),
        ),
      );
    }

    List<MapEntry<Characters, int>> dictionaryMapEntries = filterDictionary
        .entries
        .toList();

    Widget content = showDictionary
        ? Expanded(
            child: ListView.builder(
              itemCount: dictionaryMapEntries.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PhysicalModel(
                    color: Colors.white,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.none,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dictionaryMapEntries[index].key.string,
                        style: GoogleFonts.kantumruyPro(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : Expanded(
            child: Column(
              children: [
                if (isSelectionMode && onSelectAll != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          fixedSize: const Size(113, 35),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => onSelectAll!(filterSamples),
                        child: const Text("Select All"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black, width: 2),
                          fixedSize: const Size(113, 35),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          onSelectAll!([]);
                        },
                        child: const Text(
                          "Deselect All",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(15),
                    itemCount: filterSamples.length,
                    itemBuilder: (context, index) {
                      final currentSample = filterSamples[index];
                      return VectorizedTextBox(
                        isAnimated: true,
                        vecTitle: currentSample.name,
                        vecDescription: currentSample.description,
                        vecDate: currentSample.createdAt,
                        vecLabel: currentSample.stanceLabel,
                        vecQuality: currentSample.quality,
                        isSelected: selectedIndex!.contains(currentSample.id),
                        isSelectionMode: isSelectionMode,
                        onSelected: () => onSelected(currentSample),

                        onView: () {
                          if (isSelectionMode) {
                            onSelected(currentSample);
                          } else {
                            onView(currentSample);
                          }
                        },
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          );

    return content;
  }
}
