import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/services/export_import_service.dart';
import 'package:khmer_text_vectorization/model/services/sample_persistence_service.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';
import 'package:khmer_text_vectorization/ui/Screens/view_sample_screen.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';
import 'package:khmer_text_vectorization/ui/widgets/pop_up.dart';
import 'package:khmer_text_vectorization/ui/widgets/search.dart';
import 'package:khmer_text_vectorization/ui/widgets/search_result.dart';

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
    required this.refreshData,
  });

  final List<Sample> allSamples;
  final VoidCallback onVectoriezedScreen;
  final VoidCallback refreshData;

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  SortType sortType = SortType.createNewToOld;
  String topicState = "All";
  int topicIndex = 0;
  late List<Sample> samples;
  late List<Sample> sortedSamples;

  String query = "";
  void onSearch(String search) {
    setState(() {
      query = search;
    });
  }

  void onTopic(String selectedTopic, int index) {
    setState(() {
      topicState = selectedTopic;
      topicIndex = index;
      print(topicState + topicIndex.toString());
    });
  }

  void onSelectAll(List<Sample> list) {
    setState(() {
      selectedIds.clear();
      selectedIds.addAll([
        for (final sample in list)
          if (sample.id != null) sample.id!,
      ]);
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
      for (var topicLabels in topicSample.topicTags ?? []) {
        String newTopicLabel = "";
        if (topicLabels is TopicTag) {
          newTopicLabel = topicLabels.tagName;
        }
        uniqueTopic.add(newTopicLabel);
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

  final Set<int> selectedIds = {};
  bool get isSelectionMode => selectedIds.isNotEmpty;

  void onView(Sample selectedSample) async {
    if (isSelectionMode) {
      onSelected(selectedSample);
      print("onview selected");
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ViewSampleScreen(selectedSample: selectedSample);
          },
        ),
      );

      widget.refreshData();
    }
  }

  void onSelected(Sample selectedSample) {
    setState(() {
      if (selectedIds.contains(selectedSample.id)) {
        selectedIds.remove(selectedSample.id);
        print("removed");
        print(isSelectionMode);
        print(selectedIds);
      } else {
        if (selectedSample.id != null) {
          selectedIds.add(selectedSample.id!);
          print("added");
          print(isSelectionMode);
          print(selectedIds);
        }
      }
    });
  }

  void onDeleteDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: "Delete sample(s)",
          crossAxisAlignment: CrossAxisAlignment.center,
          contents: [
            SizedBox(height: 20),
            Text(
              "Deleting the sample is irreversible.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 156, 28, 19),
              ),
            ),
            SizedBox(height: 20),
            Text("Number of Items: ${selectedIds.length}"),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 75, 7, 2),
                fixedSize: Size(113, 35),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () async {
                Navigator.pop(context);

                await SamplePersistenceService.instance.deleteSamples(
                  selectedIds.toList(),
                );

                widget.refreshData();
              },
              child: const Text("Proceed"),
            ),
          ],
        );
      },
    );
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
              "${selectedIds.length} item(s)",
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
            onPressed: () async {
              Navigator.pop(context);

              await ExportImportService.exportFullDataset(
                samples,
                (SegmentingService.instance.dictionary.map(
                  (key, value) => MapEntry(value, key),
                )),
              );
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
        sorted.sort((a, b) {
          int valueA = a.stanceLabel == null ? 0 : (a.stanceLabel! ? 2 : 1);
          int valueB = b.stanceLabel == null ? 0 : (b.stanceLabel! ? 2 : 1);

          return valueB.compareTo(valueA);
        });
        break;

      case SortType.labelBadToGood:
        sorted.sort((a, b) {
          int valueA = a.stanceLabel == null ? 0 : (a.stanceLabel! ? 2 : 1);
          int valueB = b.stanceLabel == null ? 0 : (b.stanceLabel! ? 2 : 1);

          return valueA.compareTo(valueB);
        });
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
                                  selectedIds.clear();
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
                                "Select items ${selectedIds.length} ",
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () => onExportDialog(context),
                              icon: Icon(Icons.share),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.black,
                              ),
                              onPressed: () => onDeleteDialog(context),
                            ),
                          ],
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
              dictionaryTexts: {},
              searchQuery: query,
              allSamples: sortedSamples,
              topicSort: topicState,
              selectedIndex: selectedIds,
              onSelected: onSelected,
              onView: onView,
              onSelectAll: onSelectAll,
            ),
          ],
        ),
      ),
    );
  }
}
