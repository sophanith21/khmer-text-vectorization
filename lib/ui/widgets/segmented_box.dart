import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SegmentedBox extends StatelessWidget {
  SegmentedBox({super.key, Color? boxColor, required this.label}) {
    this.boxColor = boxColor ?? Color(0xFFD2E9E6);
  }

  late final Color boxColor;
  final String label;

  String get text {
    if (label.length > 20) {
      return "${label.substring(0, 20)}...";
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(
          decoration: TextDecoration.none,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
