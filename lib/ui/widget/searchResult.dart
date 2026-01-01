import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'vectorizedTextBox.dart';

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
  });

  final List<Characters> dictionaryTexts;
  final List<Sample> allSamples;
  final String searchQuery;
  final String topicSort;

  final Set<int>? selectedIndex;
  final Function(int)? onView;
  final Function(int)? onSelected;

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
            (item) => item.topicLabels.any(
              (t) => t.toLowerCase() == topicSort.toLowerCase(),
            ),
          )
          .toList();
    }

    List<Characters> filterDictionary = dictionaryTexts
        .where(
          (item) =>
              item.toString().toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    final bool showDictionary = dictionaryTexts.isNotEmpty;
    final listToShow = showDictionary ? filterDictionary : filterSamples;
    if (listToShow.isEmpty) {
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

    Widget content = showDictionary
        ? Expanded(
            child: ListView.builder(
              itemCount: filterDictionary.length,
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
                        filterDictionary[index].toString(),
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
            child: ListView.separated(
              padding: const EdgeInsets.all(15),
              itemCount: filterSamples.length,
              itemBuilder: (context, index) {
                return VectorizedTextBox(
                  vecTitle: filterSamples[index].name,
                  vecDescription: filterSamples[index].description,
                  vecDate: filterSamples[index].createdAt,
                  vecLabel: filterSamples[index].stanceLabel,
                  vecQuality: filterSamples[index].quality,
                  isSelected: selectedIndex!.contains(index),
                  isSelectionMode: selectedIndex!.isNotEmpty,
                  onSelected: selectedIndex!.isNotEmpty
                      ? () => onView!(index)
                      : () => onSelected!(index),

                  onView: () => onView!(index),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.transparent),
            ),
          );

    return content;
  }
}
