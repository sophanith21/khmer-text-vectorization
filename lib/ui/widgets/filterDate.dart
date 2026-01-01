import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'vectorized_text_box.dart';

class Filterdate extends StatelessWidget {
  const Filterdate({
    super.key,
    required this.allSamples,
    required this.dateGroup,

    required this.onView,
  });

  final List<Sample> allSamples;
  final DateTime dateGroup;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    List<Sample> filterSamples = allSamples
        .where(
          (item) =>
              item.createdAt.toString().split(" ")[0] ==
              dateGroup.toString().split(" ")[0],
        )
        .toList();

    if (filterSamples.isEmpty) {
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

    Widget content = Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: filterSamples.length,
        itemBuilder: (context, index) {
          return VectorizedTextBox(
            vecTitle: filterSamples[index].name,
            vecDescription: filterSamples[index].description,
            vecDate: filterSamples[index].createdAt,
            vecLabel: filterSamples[index].stanceLabel,
            vecQuality: filterSamples[index].quality,
            onSelected: null,
            onView: onView,
          );
        },
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.transparent),
      ),
    );

    return content;
  }
}
