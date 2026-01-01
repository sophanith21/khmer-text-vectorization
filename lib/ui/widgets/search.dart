import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  const Search({super.key, required this.onSearch});
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    // final filteredItems = widget.allitems
    //     .where(
    //       (item) =>
    //           item.toString().toLowerCase().contains(_query.toLowerCase()),
    //     )
    //     .toList();

    // return Container(
    //   height: 40,
    //   padding: const EdgeInsets.symmetric(horizontal: 8),
    //   decoration: BoxDecoration(
    //     color: const Color(0xFFE2C8A3),
    //     borderRadius: BorderRadius.circular(50),
    //     border: Border.all(color: Colors.black),
    //   ),
    //   child: TextField(
    //     onChanged: onSearch,
    //     decoration: const InputDecoration(
    //       hintText: "Search",
    //       border: InputBorder.none,
    //       fillColor: Colors.transparent,
    //       icon: Icon(Icons.search_rounded),
    //     ),
    //   ),
    // );

    return Container(
      width: 400,
      height: 32,
      decoration: BoxDecoration(
        color: Color(0xFFE2C8A3),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(50),
      ),
      child: SearchBar(
        hintText: "Search",
        trailing: [Icon(Icons.search_rounded)],
        onChanged: onSearch,
      ),
    );
  }
}
