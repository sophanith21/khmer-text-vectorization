import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.contents,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final String title;
  final List<Widget> contents;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            const BoxShadow(
              color: Colors.black,
              offset: Offset(8, 9),
              spreadRadius: 2,
            ),
            const BoxShadow(color: Color(0xFF666666), offset: Offset(8, 8)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Container(
              decoration: BoxDecoration(
                border: BoxBorder.fromLTRB(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              width: 210,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ...contents,
          ],
        ),
      ),
    );
  }
}
