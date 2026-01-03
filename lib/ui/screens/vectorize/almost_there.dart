import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';
import 'package:khmer_text_vectorization/ui/widgets/loading_dialog.dart';

class AlmostThere extends StatelessWidget {
  const AlmostThere({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onBack,
    required this.onVectorize,
    required this.quality,
    required this.parentContext,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final VoidCallback onBack;
  final BuildContext parentContext;
  final Future<void> Function(BuildContext, BuildContext) onVectorize;
  final double quality;

  Color get qualityColor {
    if (quality >= 90) {
      return const Color(0xFF2ECC71); // Vibrant Emerald Green (High Success)
    } else if (quality >= 75) {
      return const Color(0xFF34C759); // Apple Success Green
    } else if (quality >= 50) {
      return const Color(0xFFF1C40F); // Sun Flower Yellow (Steady)
    } else if (quality >= 30) {
      return const Color(0xFFE67E22); // Carrot Orange (Warning)
    } else {
      return const Color(0xFFE74C3C); // Alizarin Red (Critical)
    }
  }

  void onNext(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        bool isVectorizing = false;
        return StatefulBuilder(
          builder: (context, setState) {
            void setIsVectorizing(bool value) async {
              setState(() {
                isVectorizing = value;
              });
              if (isVectorizing) {
                await onVectorize(context, parentContext);
              }
            }

            return !isVectorizing
                ? QualityCheckDialog(
                    quality: quality,
                    qualityColor: qualityColor,
                    setIsVectorizing: setIsVectorizing,
                  )
                : LoadingDialog(
                    title: "Vectorizing",
                    description:
                        "Please wait while the app is preparing your data.",
                  );
          },
        );
      },
    );
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
            "Almost There!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const Text(
            "Please add a name and a description, so you can find it later.",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 15),

          // --- Input Field ---
          const Text(
            "Name",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 13),
          TextField(
            controller: nameController,
            textAlignVertical: TextAlignVertical(y: -1),
            maxLength: 100,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: 15),
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 13),
          TextField(
            controller: descriptionController,
            textAlignVertical: TextAlignVertical(y: -1),
            maxLines: 5,
            maxLength: 255,
            keyboardType: TextInputType.multiline,
          ),
          Spacer(),
          SizedBox(height: 26),

          // --- Stepper Navigation Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF666666),
                ),
                onPressed: onBack,
                child: Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    onNext(context);
                  } else {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          title: "ERROR",
                          contents: [
                            SizedBox(height: 20),
                            Text("Please make sure to fill the name."),
                            Text("Description is optional."),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  "Start Vectorizing",
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

class QualityCheckDialog extends StatelessWidget {
  const QualityCheckDialog({
    super.key,
    required this.quality,
    required this.qualityColor,
    required this.setIsVectorizing,
  });

  final double quality;
  final Color qualityColor;
  final ValueChanged<bool> setIsVectorizing;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "Quality Check",
      contents: [
        const SizedBox(height: 20),
        Text("Based on our system, your data quality is around: "),
        const SizedBox(height: 20),
        Stack(
          alignment: AlignmentGeometry.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: quality / 100,
                strokeWidth: 12,
                backgroundColor: Color(0xFF1F1B2E),
                valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              "${quality.toInt().toString()}%",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          "Do you want to proceed?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () => setIsVectorizing(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            fixedSize: Size(113, 35),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            "Proceed",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
