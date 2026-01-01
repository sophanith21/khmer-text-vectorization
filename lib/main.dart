import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/ui/app_theme.dart';
import 'package:khmer_text_vectorization/ui/screens/collection.dart';
import 'package:khmer_text_vectorization/ui/screens/dashboard.dart';
import 'package:khmer_text_vectorization/ui/screens/dictionary.dart';
import 'package:khmer_text_vectorization/ui/screens/settings.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/vectorize_screen.dart';
import 'package:khmer_text_vectorization/ui/widgets/navigation.dart';

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

  Future<List<Sample>> get samples async {
    return await AppDatabase.instance.getAllSamples();
  }

  Future<Set<Characters>> get dictionary async {
    await SegmentingService.instance.initDictionary();
    return SegmentingService.instance.dictionary;
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
              CustomFutureBuilder(
                futureData: samples,
                builder: (context, samples) {
                  return Dashboard(allSamples: samples);
                },
              ),

              VectorizeScreen(switchTab: onTabClick),
              CustomFutureBuilder(
                futureData: samples,
                builder: (context, samples) {
                  return Collection(
                    allSamples: samples,
                    onVectoriezedScreen: () => onTabClick(ScreenType.vectorize),
                  );
                },
              ),
              CustomFutureBuilder(
                futureData: dictionary,
                builder: (context, dictionary) {
                  return Settings(list: dictionary);
                },
              ),
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

class CustomFutureBuilder extends StatelessWidget {
  const CustomFutureBuilder({
    super.key,
    required this.futureData,
    required this.builder,
  });
  final Future<dynamic> futureData;
  final Widget Function(BuildContext, dynamic) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final futureData = snapshot.data ?? [];
        return builder(context, futureData);
      },
    );
  }
}
