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
        const SizedBox(height: 20),
        const SizedBox(
          width: 75,
          height: 75,
          child: CircularProgressIndicator(),
        ),
        const SizedBox(height: 25),
        Text(description, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
