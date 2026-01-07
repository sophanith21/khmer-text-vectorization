import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  const Search({super.key, required this.onSearch});
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFE2C8A3),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(50),
      ),
      child: SearchBar(
        hintText: "Search",
        trailing: [const Icon(Icons.search_rounded)],
        onChanged: onSearch,
      ),
    );
  }
}
