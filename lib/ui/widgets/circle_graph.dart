import 'package:flutter/material.dart';

class CircleGraph extends StatelessWidget {
  const CircleGraph({
    super.key,
    required this.allPercentageValue,
    required this.allPercentage,
    required this.size,
    required this.isShowText,
  });

  final double allPercentageValue;
  final double allPercentage;
  final double size;
  final bool isShowText;

  Color get qualityColor {
    if (allPercentage >= 90) {
      return const Color(0xFF2ECC71); // Vibrant Emerald Green (High Success)
    } else if (allPercentage >= 75) {
      return const Color(0xFF34C759); // Apple Success Green
    } else if (allPercentage >= 50) {
      return const Color(0xFFF1C40F); // Sun Flower Yellow (Steady)
    } else if (allPercentage >= 30) {
      return const Color(0xFFE67E22); // Carrot Orange (Warning)
    } else {
      return const Color(0xFFE74C3C); // Alizarin Red (Critical)
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: (size / 10) * 1.25,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: allPercentageValue,
              strokeWidth: (size / 10) * 1.5,
              strokeCap: StrokeCap.round,
              color: qualityColor,
            ),
          ),

          isShowText
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Avg. Quality",
                      style: TextStyle(
                        fontSize: (size / 10) * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${allPercentage.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: (size / 10) * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
