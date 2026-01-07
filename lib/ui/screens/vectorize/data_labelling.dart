import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/services/suggest_tags_service.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';

class DataLabelling extends StatefulWidget {
  const DataLabelling({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.updateStance,
    required this.updateTags,
    required this.initStance,
    required this.initTopicTags,
  });
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<bool> updateStance;
  final ValueChanged<Set<TopicTag>> updateTags;
  final bool? initStance;
  final Set<TopicTag> initTopicTags;

  @override
  State<DataLabelling> createState() => _DataLabellingState();
}

class _DataLabellingState extends State<DataLabelling> {
  bool? selectedStance;
  Set<TopicTag> topicTags = {};
  Set<TopicTag> suggestedTags = {};

  @override
  void initState() {
    super.initState();
    _loadInitialSuggestionTags();
    topicTags = {...widget.initTopicTags};
    selectedStance = widget.initStance;
  }

  void onStanceTap(bool value) {
    setState(() {
      selectedStance = value;
    });

    widget.updateStance(value);
  }

  Future<void> _loadInitialSuggestionTags() async {
    final initial = await SuggestTagsService.instance.suggestionTags;
    setState(() {
      suggestedTags = initial;
    });
  }

  Future<void> onAdd() async {
    Set<TopicTag>? newTopicTags = await showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(51),
      builder: (context) {
        return EditTagsDialog(
          topicTags: topicTags,
          initialSuggestion: suggestedTags,
        );
      },
    );
    if (newTopicTags != null) {
      setState(() {
        topicTags = newTopicTags;
      });
      widget.updateTags(topicTags);
      for (final tag in topicTags) {
        SuggestTagsService.instance.addNewTag(tag);
      }
    }
  }

  void onRemove(String object) {
    if (topicTags.isNotEmpty) {
      setState(() {
        topicTags.removeWhere((e) => e.tagName == object);
      });
      widget.updateTags(topicTags);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Content ---
                const Text(
                  "Labeling Data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const Text(
                  "Please label the text before and giving the correct information of tags",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 28),

                // --- Stance Label ---
                const Text(
                  "STANCE LABEL",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 11),
                CustomBinaryRadioMenu(
                  selectedStance: selectedStance,
                  onStanceTap: onStanceTap,
                ),
                const SizedBox(height: 28),

                // --- Topic Tags ---
                const Text(
                  "TOPIC TAGS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 11),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          blurStyle: BlurStyle.outer,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),

                    padding: const EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...topicTags.map(
                            (e) => CustomTopicChip(
                              label: e.tagName,
                              onRemove: onRemove,
                            ),
                          ),

                          GestureDetector(
                            onTap: onAdd,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFD2E9E6),
                              ),
                              width: 25,
                              height: 25,
                              child: const Icon(Icons.add, size: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),

          // --- Steppers Navigation Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF666666),
                ),
                onPressed: widget.onBack,
                child: const Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: widget.onNext,
                child: const Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditTagsDialog extends StatefulWidget {
  const EditTagsDialog({
    super.key,
    required this.topicTags,
    required this.initialSuggestion,
  });
  final Set<TopicTag> topicTags;
  final Set<TopicTag> initialSuggestion;

  @override
  State<EditTagsDialog> createState() => _EditTagsDialogState();
}

class _EditTagsDialogState extends State<EditTagsDialog> {
  Set<TopicTag> currentTopicTags = {};
  List<TopicTag> newSuggestionTags = [];
  @override
  void initState() {
    super.initState();
    currentTopicTags = {...widget.topicTags};
    newSuggestionTags = widget.initialSuggestion.toList();
  }

  void onAddInDialog(TopicTag value) {
    if (value.tagName.isNotEmpty) {
      setState(() {
        currentTopicTags.add(value);
      });
    }
  }

  void onRemoveInDialog(String object) {
    setState(() {
      currentTopicTags.removeWhere((e) => e.tagName == object);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "Edit Tags",
      contents: [
        const SizedBox(height: 20),
        const Text(
          "Search for suggested tag’s topic or you can create your own custom tags to label the data",
        ),
        const SizedBox(height: 20),
        SearchAnchor(
          viewConstraints: BoxConstraints(minHeight: 40, maxHeight: 350),
          isFullScreen: false,
          suggestionsBuilder: (context, controller) {
            final filteredList = newSuggestionTags
                .where(
                  (tag) => tag.tagName.toLowerCase().contains(
                    controller.text.toLowerCase(),
                  ),
                )
                .toList();

            return [
              ListView.builder(
                shrinkWrap: true,
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredList[index].tagName),
                    onTap: () {
                      onAddInDialog(filteredList[index]);
                      controller.clear();
                      controller.closeView(filteredList[index].tagName);
                    },
                  );
                },
              ),
            ];
          },
          builder: (context, controller) {
            return SearchBar(
              onTap: () => controller.openView(),
              onChanged: (_) => controller.openView(),
              leading: const Icon(Icons.search, size: 20),
              trailing: [
                IconButton(
                  onPressed: () async {
                    TopicTag newTag = TopicTag(tagName: controller.text);
                    await SuggestTagsService.instance.addNewTag(newTag);
                    onAddInDialog(newTag);
                  },
                  icon: const Icon(Icons.add, size: 20),
                  padding: const EdgeInsets.all(0),
                ),
              ],

              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              side: const WidgetStatePropertyAll(
                BorderSide(color: Color(0xFF666666), width: 1.0),
              ),

              backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9)),
              constraints: const BoxConstraints(
                minHeight: 31.0,
                maxHeight: 31.0,
              ),
              controller: controller,
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              const BoxShadow(
                color: Colors.black,
                blurRadius: 4,
                blurStyle: BlurStyle.outer,
                offset: Offset(0, 0),
              ),
            ],
          ),

          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ...currentTopicTags.map(
                  (e) => CustomTopicChip(
                    label: e.tagName,
                    onRemove: onRemoveInDialog,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, currentTopicTags);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            fixedSize: const Size(113, 35),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text(
            "Confirm",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class CustomTopicChip extends StatelessWidget {
  const CustomTopicChip({
    super.key,
    required this.label,
    required this.onRemove,
  });
  final String label;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFD2E9E6),
        borderRadius: BorderRadius.circular(50),
      ),

      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        spacing: 9,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          Container(width: 1, height: 14, color: Colors.black),
          GestureDetector(
            onTap: () {
              onRemove(label);
            },
            child: const Icon(Icons.close, size: 15),
          ),
        ],
      ),
    );
  }
}

class CustomBinaryRadioMenu extends StatelessWidget {
  const CustomBinaryRadioMenu({
    super.key,
    required this.selectedStance,
    required this.onStanceTap,
  });

  final bool? selectedStance;
  final ValueChanged<bool> onStanceTap;

  Color get positiveBgColor => selectedStance == null
      ? Colors.transparent
      : (selectedStance! ? Color(0xFF6C6C6C) : Colors.white);
  Color get negativeBgColor => selectedStance == null
      ? Colors.transparent
      : (selectedStance! ? Colors.white : Color(0xFF6C6C6C));

  Color get postitiveColor => selectedStance == null
      ? Colors.black
      : (selectedStance! ? Colors.white : Colors.black);

  Color get negativeColor => selectedStance == null
      ? Colors.black
      : (selectedStance! ? Colors.black : Colors.white);

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onStanceTap(true),
            child: Container(
              decoration: BoxDecoration(
                color: positiveBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

              child: Row(
                spacing: 10,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: postitiveColor, width: 2),
                    ),
                    width: 24,
                    height: 24,
                  ),
                  Text(
                    "Positive",
                    style: TextStyle(
                      color: postitiveColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onStanceTap(false),
            child: Container(
              decoration: BoxDecoration(
                color: negativeBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

              child: Row(
                spacing: 10,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: negativeColor, width: 2),
                    ),
                    width: 24,
                    height: 24,
                  ),
                  Text(
                    "Negative",
                    style: TextStyle(
                      color: negativeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
