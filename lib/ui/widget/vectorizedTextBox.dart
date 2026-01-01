import 'package:flutter/material.dart';
import './circleGraph.dart';

class VectorizedTextBox extends StatelessWidget {
  const VectorizedTextBox({
    super.key,
    required this.vecTitle,
    required this.vecDescription,
    required this.vecDate,
    required this.vecLabel,
    required this.vecQuality,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onView,
    this.onSelected,
  });

  final String vecTitle;
  final String vecDescription;
  final DateTime vecDate;
  final int vecLabel;
  final double vecQuality;

  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onView;
  final VoidCallback? onSelected;

  String get label => vecLabel == 1 ? "Positive" : "Negative";

  double get qualityValue => vecQuality.roundToDouble() / 100;

  IconData get iconChecked => isSelected
      ? Icons.radio_button_checked_outlined
      : Icons.radio_button_unchecked_outlined;
  double get positionSelected => isSelected ? 80 : 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 6,
            left: 6,
            right: -6,
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFE2C8A3),
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Icon(iconChecked)],
              ),
            ),
          ),

          Positioned.fill(
            left: positionSelected,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: BoxBorder.all(color: Colors.black),
                borderRadius: BorderRadius.circular(13),
              ),
              child: ListTile(
                onTap: onView,
                onLongPress: onSelected,
                title: Text(
                  vecTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vecDescription,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      vecDate.toString().split(" ")[0],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),

                isThreeLine: true,

                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Label: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          label,
                          style: const TextStyle(color: Color(0xFFAC7F5E)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quality",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(width: 5),

                        CircleGraph(
                          allPercentage: vecQuality,
                          allPercentageValue: qualityValue,
                          size: 20,
                          isShowText: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
