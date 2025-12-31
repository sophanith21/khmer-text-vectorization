import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/ui/app_theme.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/vectorize_screen.dart';
import 'ui/widgets/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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

  void switchTab(ScreenType newScreen) {
    setState(() {
      currentScreen = newScreen;
    });
  }

  Future<List<Sample>> get samples async {
    return await AppDatabase.instance.getAllSamples();
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
      title: 'Khmer Text Vectorization',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: Text(appBarTitle)),
        body: SafeArea(
          child: IndexedStack(
            index: currentScreen.index,
            children: [
              Placeholder(),
              VectorizeScreen(switchTab: switchTab),

              FutureBuilder(
                future: samples,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final samples = snapshot.data ?? [];
                  return ListView(
                    children: [...samples.map((e) => Text(e.name))],
                  );
                },
              ),
              Placeholder(),
            ],
          ),
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
