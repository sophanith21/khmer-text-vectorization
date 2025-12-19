import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;

  List<String> list = await db.getAllWords();
  print("list $list");
  runApp(MyApp(list: list.toSet()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.list});
  final Set<String> list;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(
        body: ListView(
          children: [
            ...list.map((e) => Text(e, style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
    );
  }
}
