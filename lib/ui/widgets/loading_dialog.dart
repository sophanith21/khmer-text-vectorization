import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    super.key,
    required this.title,
    required this.description,
  });
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      contents: [
        SizedBox(height: 20),
        SizedBox(width: 75, height: 75, child: CircularProgressIndicator()),
        SizedBox(height: 25),
        Text(description, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
