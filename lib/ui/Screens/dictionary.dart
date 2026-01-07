import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_view_screen_widget.dart';
import 'package:khmer_text_vectorization/ui/widgets/segmented_box.dart';

class Dictionary extends StatefulWidget {
  const Dictionary({super.key, required this.list, required this.refreshData});

  final Map<Characters, int> list;
  final VoidCallback refreshData;

  @override
  State<Dictionary> createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  String searchQuery = "";
  List<MapEntry<Characters, int>> get filteredList => widget.list.entries
      .where(
        (e) => e.key.string.toLowerCase().startsWith(searchQuery.toLowerCase()),
      )
      .toList();

  Future<void> onWordTap(MapEntry<Characters, int> word) async {
    final newWord = await showDialog(
      context: context,
      builder: (context) {
        return EditingWordDialog(word: word);
      },
    );

    if (newWord != null) {
      if (newWord is String) {
        await SegmentingService.instance.editWord(newWord.characters, word.key);
        widget.refreshData();
      } else if (newWord is bool && newWord == true) {
        print("DELETE");
        await SegmentingService.instance.deleteWord(word.key);
        widget.refreshData();
      }
    }
  }

  @override
  void didUpdateWidget(covariant Dictionary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.list != oldWidget.list) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomViewScreenWidget(
      title: "Dictionary",
      crossAxisAlignment: CrossAxisAlignment.center,
      contents: [
        Expanded(
          child: ListView.separated(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onWordTap(filteredList[index]),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 0),
                        blurRadius: 4,
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  margin: const EdgeInsets.all(5),
                  child: Text(
                    filteredList[index].key.string,
                    style: const TextStyle(
                      fontFamily: "KantumruyPro",
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 10),
          ),
        ),
      ],
      leading: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: SearchBar(
                trailing: [const Icon(Icons.search)],
                hintText: "Search",
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                side: const WidgetStatePropertyAll(
                  BorderSide(color: Color(0xFF666666), width: 1.0),
                ),

                constraints: const BoxConstraints(
                  minHeight: 32.0,
                  maxHeight: 32.0,
                ),

                onChanged: (value) => setState(() {
                  searchQuery = value;
                }),
              ),
            ),
          ),
          IconButton(
            onPressed: onAddWord,
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Future<void> onAddWord() async {
    final Characters? newWord =
        await showDialog(
              context: context,
              builder: (context) {
                return AddNewWordDialog();
              },
            )
            as Characters?;

    if (newWord != null) {
      await SegmentingService.instance.addNewWord(newWord);
      widget.refreshData();
    }
  }
}

class AddNewWordDialog extends StatefulWidget {
  const AddNewWordDialog({super.key});

  @override
  State<AddNewWordDialog> createState() => _AddNewWordDialogState();
}

class _AddNewWordDialogState extends State<AddNewWordDialog> {
  String newWord = "";

  void onChange(String value) {
    setState(() {
      newWord = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "Add new word",
      contents: [
        const SizedBox(height: 20),
        SizedBox(
          height: 120,
          child: TextField(
            textAlignVertical: TextAlignVertical(y: -1),
            onChanged: onChange,
            expands: true,
            maxLength: null,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontFamily: "KantumruyPro"),
          ),
        ),
        const SizedBox(height: 20),
        if (newWord.isNotEmpty) SegmentedBox(label: newWord),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (newWord.isNotEmpty) {
              Navigator.pop(context, newWord.characters);
            } else {
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            fixedSize: Size(113, 35),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text(
            "Confirm Add",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class EditingWordDialog extends StatefulWidget {
  const EditingWordDialog({super.key, required this.word});

  final MapEntry<Characters, int> word;

  @override
  State<EditingWordDialog> createState() => _EditingWordDialogState();
}

class _EditingWordDialogState extends State<EditingWordDialog> {
  TextEditingController textEditingController = TextEditingController();
  String newText = "";
  bool get deletable =>
      !SegmentingService.instance.usedWords.contains(widget.word.value);
  @override
  void initState() {
    textEditingController.text = widget.word.key.string;
    super.initState();
  }

  void onTextFieldChange(String value) {
    if (value != widget.word.key.string) {
      setState(() {
        newText = value;
      });
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "Edit word",
      contents: [
        const SizedBox(height: 20),
        SegmentedBox(label: widget.word.key.string),
        const SizedBox(height: 20),
        SizedBox(
          height: 120,
          child: TextField(
            textAlignVertical: TextAlignVertical(y: -1),
            controller: textEditingController,
            onChanged: onTextFieldChange,
            expands: true,
            maxLength: null,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontFamily: "KantumruyPro"),
          ),
        ),
        const SizedBox(height: 20),
        if (newText.isNotEmpty) SegmentedBox(label: newText),
        SizedBox(height: 20),
        if (!deletable)
          const Text(
            "Note: Delete is disabled because your samples are using the word.",
            style: TextStyle(
              color: Color(0xFFA3A3A3),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 25,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC6C6C6),
                fixedSize: Size(113, 35),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: deletable
                  ? () {
                      Navigator.pop(context, true);
                    }
                  : null,
              child: const Text(
                "Delete word",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (newText.isNotEmpty) {
                  Navigator.pop(context, newText);
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                fixedSize: Size(113, 35),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                "Confirm Edit",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
