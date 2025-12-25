import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/app_theme.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/ui/Screens/vectorize_screen.dart';
import './ui/navigation.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.dictionary});
  final Set<Characters> dictionary;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScreenType currentScreen = ScreenType.dashboard;
  void onTabClick(ScreenType newScreen) {
    setState(() {
      currentScreen = newScreen;
    });
  }

  String get appBarTitle {
    switch (currentScreen) {
      case ScreenType.dashboard:
        return "Dashboard";
      case ScreenType.vectorize:
        return "Vectorize Text";
      case ScreenType.collection:
        return "Corpus Collection";
      case ScreenType.setting:
        return "Settings";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: Text(appBarTitle)),
        body: IndexedStack(
          index: currentScreen.index,
          children: [
            Placeholder(),
            VectorizeScreen(),
            Placeholder(),
            Placeholder(),
          ],
        ),

        bottomNavigationBar: SafeArea(
          child: Navigation(
            currentScreen: currentScreen,
            onTabClick: onTabClick,
          ),
        ),
      ),
    );
  }
}
