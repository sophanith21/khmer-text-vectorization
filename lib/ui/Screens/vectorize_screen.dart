import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/main.dart';

class VectorizeScreen extends StatefulWidget {
  const VectorizeScreen({super.key});

  @override
  State<VectorizeScreen> createState() => _VectorizeScreenState();
}

class _VectorizeScreenState extends State<VectorizeScreen> {
  int currentStep = 0;
  @override
  Widget build(BuildContext context) {
    return Stepper(
      type: StepperType.horizontal,

      steps: [
        Step(
          isActive: currentStep == 0,
          label: Text(
            "Text Input",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          title: const SizedBox.shrink(),
          content: Text("What do you want to know?"),
        ),
        Step(
          isActive: currentStep == 1,
          title: const SizedBox.shrink(),
          label: Text(
            "Segmentation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("What do you want to know?"),
        ),
        Step(
          isActive: currentStep == 2,
          title: const SizedBox.shrink(),
          label: Text(
            "Data Labelling",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("What do you want to know?"),
        ),
      ],
      onStepTapped: (value) {
        setState(() {
          currentStep = value;
        });
      },
      currentStep: currentStep,
    );
  }
}
