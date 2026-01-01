// import 'package:flutter/material.dart';
// import 'package:khmer_text_vectorization/data/app_database.dart';
// import 'ui/widget/navigation.dart';
// import 'ui/widget/vectorizedSearch.dart';

// import 'ui/page/dashboard.dart';
// import 'ui/page/collection.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final db = AppDatabase.instance;

//   List<String> list = await db.getAllWords();
//   print("list $list");
//   runApp(MyApp(list: list.toSet()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key, required this.list});
//   final Set<String> list;
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
//       home: Scaffold(
//         body: Collection(list: list),
//         // Dashboard(),

//         // Container(child: Search(allitems: list)),

//         // ListView(
//         //   children: [
//         //     Expanded(child: Search(allitems: list)),
//         //     ...list.map((e) => Text(e, style: TextStyle(color: Colors.black))),
//         //   ],
//         // ),
//         bottomNavigationBar: Navigation(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/app_theme.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/ui/Screens/vectorize_screen.dart';

import './data/samples.dart';

import './ui/widget/navigation.dart';
import 'ui/Screens/dashboard.dart';
import 'ui/Screens/collection.dart';
import 'ui/Screens/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;

  List<String> list = await db.getAllWords();
  List<Characters> wordsList = [];
  for (String wordString in list) {
    Characters word = Characters(wordString);
    wordsList.add(word);
  }

  runApp(MyApp(dictionary: wordsList.toSet(), vetorizes: samples));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.dictionary, required this.vetorizes});
  final Set<Characters> dictionary;
  //!testing
  final List<Sample> vetorizes;

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
        appBar: AppBar(
          title: Text(
            appBarTitle,
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
        ),
        body: IndexedStack(
          index: currentScreen.index,
          children: [
            Dashboard(allSamples: widget.vetorizes),
            VectorizeScreen(),
            Collection(
              allSamples: widget.vetorizes,
              onVectoriezedScreen: () => onTabClick(ScreenType.vectorize),
            ),
            Settings(list: widget.dictionary),
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
