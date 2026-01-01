import 'package:flutter/material.dart';
import '../widget/search.dart';
import '../widget/searchResult.dart';

class Dictionary extends StatefulWidget {
  const Dictionary({super.key, required this.list});

  final Set<Characters> list;

  @override
  State<Dictionary> createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  String query = "";
  void onSearch(String search) {
    setState(() {
      query = search;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dictionary",
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_backspace_rounded),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Search(onSearch: onSearch),

            Container(
              margin: EdgeInsets.all(20),
              height: 2,
              width: 425,
              color: Colors.black,
            ),

            Searchresult(
              dictionaryTexts: widget.list.toList(),
              searchQuery: query,
              allSamples: [],
              topicSort: "",
              selectedIndex: null,
              onSelected: null,
              onView: null,
            ),
          ],
        ),
      ),
    );
  }
}
