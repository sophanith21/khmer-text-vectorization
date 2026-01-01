import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/data/samples.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/ui/widget/popUp.dart';
import 'package:khmer_text_vectorization/ui/widget/searchResult.dart';
import 'package:path/path.dart';
import '../widget/vectorizedTextBox.dart';
import '../widget/search.dart';

enum SortType {
  qualityHighToLow,
  qualityLowToHigh,

  createNewToOld,
  createOldToNew,

  nameAsc,
  nameDesc,

  labelGoodToBad,
  labelBadToGood,
}

class Collection extends StatefulWidget {
  const Collection({
    super.key,
    required this.allSamples,
    required this.onVectoriezedScreen,
  });

  final List<Sample> allSamples;
  final VoidCallback onVectoriezedScreen;

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  SortType sortType = SortType.createNewToOld;
  late List<Sample> samples;
  late List<Sample> sortedSamples;

  String query = "";
  void onSearch(String search) {
    setState(() {
      query = search;
    });
  }

  String topicState = "All";
  int topicIndex = 0;
  void onTopic(String selectedTopic, int index) {
    setState(() {
      topicState = selectedTopic;
      topicIndex = index;
      print(topicState + topicIndex.toString());
    });
  }

  Color getButtonStyle(bool isIndex) => isIndex ? Colors.black : Colors.white;

  @override
  void initState() {
    super.initState();
    samples = widget.allSamples;
    sortedSamples = samples;

    //intial sort new to old
    sortedSamples = sortSamples(samples, sortType);
  }

  List<String> get topic {
    List<String> uniqueTopic = ["All"];
    for (var topicSample in samples) {
      for (var topicLabels in topicSample.topicLabels) {
        uniqueTopic.add(topicLabels);
      }
    }
    return uniqueTopic.toSet().toList();
  }

  void onSorted(SortType sort) {
    setState(() {
      sortType = sort;
      sortedSamples = sortSamples(samples, sort);
    });
  }

  final Set<int> seletedIndex = {};
  bool get isSelectionMode => seletedIndex.isNotEmpty;

  void onView(int index) {
    if (isSelectionMode) {
      onSelected(index);
      print("onview selected");
    } else {
      //todo: go to view detail screen
      print("pressed view detail");
    }
  }

  void onSelected(int index) {
    setState(() {
      // print("long pressed");
      if (seletedIndex.contains(index)) {
        seletedIndex.remove(index);
        print("removed");
        print(isSelectionMode);
        print(seletedIndex);
      } else {
        seletedIndex.add(index);
        print("added");
        print(isSelectionMode);
        print(seletedIndex);
      }
    });
  }

  void onExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Popup(
        title: "Export",
        content: Column(
          children: [
            const Text(
              "Do you want export the selected items from your collection?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            Text(
              "${seletedIndex.length} item(s)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),

            const SizedBox(height: 20),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF666666)),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "No",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //todo export items
            },
            child: const Text(
              "Yes",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  List<Sample> sortSamples(List<Sample> list, SortType type) {
    final sorted = List<Sample>.from(list);

    switch (type) {
      case SortType.qualityHighToLow:
        sorted.sort((a, b) => b.quality.compareTo(a.quality));
        break;

      case SortType.qualityLowToHigh:
        sorted.sort((a, b) => a.quality.compareTo(b.quality));
        break;

      case SortType.createNewToOld:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case SortType.createOldToNew:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case SortType.nameAsc:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case SortType.nameDesc:
        sorted.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;

      case SortType.labelGoodToBad:
        sorted.sort((a, b) => b.stanceLabel.compareTo(a.stanceLabel));
        break;

      case SortType.labelBadToGood:
        sorted.sort((a, b) => a.stanceLabel.compareTo(b.stanceLabel));
        break;
    }

    return sorted;
  }

  PopupMenuItem sortingPopUp({
    required String title,
    required String titleAsc,
    required SortType sortAsc,
    required String titleDesc,
    required SortType sortDesc,
    required IconData icon,
  }) {
    return PopupMenuItem(
      child: PopupMenuButton(
        onSelected: onSorted,
        tooltip: "Sort by $title",
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text("Sort by $title"),
          ],
        ),
        itemBuilder: (context) => [
          PopupMenuItem(value: sortAsc, child: Text(titleAsc)),
          PopupMenuItem(value: sortDesc, child: Text(titleDesc)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            //title
            // Text(
            //   title,
            //   style: TextStyle(
            //     fontSize: 40,
            //     fontWeight: FontWeight.bold,
            //     shadows: [
            //       Shadow(
            //         blurRadius: 0,
            //         color: Color(0xFFE2C8A3),
            //         offset: Offset(3, 3),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox.shrink(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton(
                  tooltip: "Sort by",
                  borderRadius: BorderRadius.circular(20),
                  icon: const Icon(Icons.sort_rounded),
                  itemBuilder: (context) => [
                    sortingPopUp(
                      title: "Name",
                      titleAsc: "Ascending",
                      sortAsc: SortType.nameAsc,
                      titleDesc: "Descending",
                      sortDesc: SortType.nameDesc,
                      icon: Icons.text_fields_rounded,
                    ),

                    sortingPopUp(
                      title: "Created",
                      titleAsc: "Oldest → Newset",
                      sortAsc: SortType.createOldToNew,
                      titleDesc: "Newest → Oldest",
                      sortDesc: SortType.createNewToOld,
                      icon: Icons.create_rounded,
                    ),

                    sortingPopUp(
                      title: "Label",
                      titleAsc: "Negative → Positive",
                      sortAsc: SortType.labelBadToGood,
                      titleDesc: "Positive → Negative",
                      sortDesc: SortType.labelGoodToBad,
                      icon: Icons.label_important_outline_rounded,
                    ),

                    sortingPopUp(
                      title: "Quality",
                      titleAsc: "Low → High",
                      sortAsc: SortType.qualityLowToHigh,
                      titleDesc: "High → Low",
                      sortDesc: SortType.qualityHighToLow,
                      icon: Icons.high_quality_outlined,
                    ),
                  ],
                ),

                Expanded(child: Search(onSearch: onSearch)),

                IconButton(
                  onPressed: widget.onVectoriezedScreen,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),

            SizedBox(
              height: 35,
              child: isSelectionMode
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  seletedIndex.clear();
                                });
                              },
                              icon: const Icon(Icons.cancel_outlined),
                            ),

                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(),
                              ),
                              child: Text(
                                "Select items ${seletedIndex.length} ",
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton(
                          onPressed: () => onExportDialog(context),
                          child: const Text("Export"),
                        ),
                      ],
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: topic.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: getButtonStyle(
                                topicIndex == index,
                              ),
                            ),
                            child: Text(
                              topic[index],
                              style: TextStyle(
                                color: getButtonStyle(topicIndex != index),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => onTopic(topic[index], index),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.transparent),
                    ),
            ),

            Container(height: 2, width: 370, color: Colors.black),

            Searchresult(
              dictionaryTexts: [],
              searchQuery: query,
              allSamples: sortedSamples,
              topicSort: topicState,
              selectedIndex: seletedIndex,
              onSelected: onSelected,
              onView: onView,
            ),
          ],
        ),
      ),
    );
  }
}
