import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/services/sample_persistence_service.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/ui/app_theme.dart';
import 'package:khmer_text_vectorization/ui/screens/collection.dart';
import 'package:khmer_text_vectorization/ui/screens/dashboard.dart';
import 'package:khmer_text_vectorization/ui/screens/settings.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/vectorize_screen.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_future_builder.dart';
import 'package:khmer_text_vectorization/ui/widgets/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SamplePersistenceService.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScreenType currentScreen = ScreenType.dashboard;

  void refreshData() {
    setState(() {});
  }

  void onTabClick(ScreenType newScreen) {
    setState(() {
      currentScreen = newScreen;
    });
  }

  Future<List<Sample>> get samples async {
    return await AppDatabase.instance.getAllSamples();
  }

  Future<Map<Characters, int>> get dictionary async {
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
              CustomFutureBuilder<List<Sample>>(
                futureData: samples,
                defaultValue: [],
                builder: (context, samples) {
                  return Dashboard(allSamples: samples);
                },
              ),

              VectorizeScreen(switchTab: onTabClick),
              CustomFutureBuilder<List<Sample>>(
                futureData: samples,
                defaultValue: [],
                builder: (context, samples) {
                  return Collection(
                    refreshData: refreshData,
                    allSamples: samples,
                    onVectoriezedScreen: () => onTabClick(ScreenType.vectorize),
                  );
                },
              ),
              CustomFutureBuilder<Map<Characters, int>>(
                defaultValue: {},
                futureData: dictionary,
                builder: (context, dictionary) {
                  return Settings(list: dictionary, refreshData: refreshData);
                },
              ),
            ],
          ),
        ),

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Navigation(
              currentScreen: currentScreen,
              onTabClick: onTabClick,
            ),
          ),
        ),
      ),
    );
  }
}
