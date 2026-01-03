import 'package:flutter/material.dart';

class CustomViewScreenWidget extends StatelessWidget {
  const CustomViewScreenWidget({
    super.key,
    required this.title,
    required this.contents,
    this.leading,
    required this.crossAxisAlignment,
  });

  final String title;
  final Widget? leading;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> contents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
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
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(7),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => {Navigator.pop(context)},
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            if (leading != null) leading!,

            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              color: Colors.black,
              width: double.infinity,
              height: 2,
            ),
            ...contents,
          ],
        ),
      ),
    );
  }
}
