import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';

class KHTextInput extends StatefulWidget {
  const KHTextInput({super.key, required this.onNext, required this.initValue});

  final ValueChanged<String> onNext;
  final String initValue;

  @override
  State<KHTextInput> createState() => _KHTextInputState();
}

class _KHTextInputState extends State<KHTextInput> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.initValue;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Content ---
          const Text(
            "Khmer Text Input",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const Text.rich(
            TextSpan(
              text: "Please enter or paste only",
              style: TextStyle(fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                  text: " Khmer text ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "below to segment them.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Tip: For optimal vectorization and segmentation, aim for a length of 21–150 words.",
            style: TextStyle(
              color: Color(0xFFA3A3A3),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),
          // --- Input Field ---
          Expanded(
            child: TextField(
              controller: textController,
              textAlignVertical: TextAlignVertical(y: -1),
              expands: true,
              maxLength: null,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: "KantumruyPro"),
            ),
          ),
          const SizedBox(height: 26),

          // --- Stepper Navigation Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF666666),
                ),
                onPressed: null,
                child: const Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (textController.text.isEmpty) {
                    return await showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          title: "ERROR",
                          contents: [
                            const SizedBox(height: 20),
                            const Text("Input must not be empty."),
                          ],
                        );
                      },
                    );
                  }
                  widget.onNext(textController.text);
                },
                child: const Text(
                  "Start Segmenting",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
