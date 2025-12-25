import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/app_theme.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;

  List<String> list = await db.getAllWords();
  List<Characters> wordsList = [];
  for (String wordString in list) {
    Characters word = Characters(wordString);
    wordsList.add(word);
  }

  runApp(MyApp(dictionary: wordsList.toSet()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.dictionary});
  final Set<Characters> dictionary;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: Text("Vectorize Text")),
        body: Wizard(),
      ),
    );
  }
}

class Wizard extends StatefulWidget {
  const Wizard({super.key});

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
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
