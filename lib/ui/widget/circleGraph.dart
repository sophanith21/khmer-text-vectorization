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
              color: Color(0xFFE2C8A3),
            ),
          ),
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: allPercentageValue,
              strokeWidth: (size / 10) * 1.5,
              strokeCap: StrokeCap.round,
              color: Colors.green,
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
