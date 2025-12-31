import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key, required this.allitems});
  final Set<String> allitems;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.allitems
        .where((item) => item.toLowerCase().contains(_query))
        .toList();
    return Column(
      children: [
        SearchBar(
          hintText: 'Search',
          leading: Icon(Icons.search),
          trailing: [IconButton(icon: Icon(Icons.close), onPressed: () {})],
          onChanged: (value) {
            setState(() {
              _query = value;
            });
            print(value);
          },
        ),

        Expanded(
          child: ListView(
            children: [
              ...filteredItems.map(
                (e) => Text(e, style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
