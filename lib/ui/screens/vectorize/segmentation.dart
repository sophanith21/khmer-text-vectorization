import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khmer_text_vectorization/model/segment.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';

class Segmentation extends StatefulWidget {
  const Segmentation({
    super.key,
    required this.segmentedText,
    required this.onBack,
    required this.onNext,
    required this.updateSegmentedText,
  });

  final List<Segment> segmentedText;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<List<Segment>> updateSegmentedText;

  @override
  State<Segmentation> createState() => _SegmentationState();
}

class _SegmentationState extends State<Segmentation> {
  List<Segment> segmentedTextState = [];

  @override
  void initState() {
    super.initState();
    segmentedTextState = [...widget.segmentedText];
  }

  @override
  void didUpdateWidget(covariant Segmentation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.segmentedText != oldWidget.segmentedText) {
      setState(() {
        segmentedTextState = List.from(widget.segmentedText);
      });
    }
  }

  // For false alarm
  void rectifyWord(int index) {
    setState(() {
      segmentedTextState[index] = Segment(segmentedTextState[index].text, true);
      updateDictionary(segmentedTextState[index].text);
    });
    widget.updateSegmentedText(segmentedTextState);
  }

  void removeWord(int index) {
    setState(() {
      segmentedTextState.removeAt(index);
    });
  }

  void splitWord(List<Characters> newWords, int index) {
    if (newWords.isNotEmpty) {
      List<Segment> newWordsEntry = [];
      setState(() {
        segmentedTextState[index] = Segment(newWords[0], true);
        updateDictionary(newWords[0]);

        for (int i = 1; i < newWords.length; i++) {
          newWordsEntry.add(Segment(newWords[i], true));
          updateDictionary(newWords[i]);
        }
        segmentedTextState.insertAll(index + 1, newWordsEntry);
      });
      widget.updateSegmentedText(segmentedTextState);
    }
  }

  // TO BE ADD: Add the word to the dictionary
  void mergeWord(int currentIndex, int indexToMerge) {
    if (segmentedTextState.length >= 2) {
      setState(() {
        var currentWord = segmentedTextState[currentIndex];
        var wordToMerge = segmentedTextState[indexToMerge];
        currentWord = Segment(currentWord.text + wordToMerge.text, false);
        segmentedTextState[currentIndex] = currentWord;
        segmentedTextState.removeAt(indexToMerge);
      });
      widget.updateSegmentedText(segmentedTextState);
    }
  }

  bool isSegmentedTextCleaned() {
    for (final segment in segmentedTextState) {
      if (!segment.isKnown) {
        return false;
      }
    }
    return true;
  }

  void updateDictionary(Characters newWord) {
    SegmentingService.instance.addNewWord(newWord);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Content ---
          const Text(
            "Segmenting Text",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const Text(
            "Please select a text that you want to manually segment or fix.",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            "Current Word Count: ${segmentedTextState.length}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),

          // --- Segmented Texts Box ---
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
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
                    ...segmentedTextState.indexed.map(
                      (e) => TextBox(
                        label: e.$2.text.toString(),
                        isSegmented: e.$2.isKnown,
                        onMerge: mergeWord,
                        onSplit: splitWord,
                        onFalseAlarm: rectifyWord,
                        onRemove: removeWord,
                        index: e.$1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 26),

          // --- Stepper Navigation Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF666666),
                ),
                onPressed: widget.onBack,
                child: Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: onStartLabellingPress,
                child: Text(
                  "Start Labelling",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onStartLabellingPress() async {
    if (isSegmentedTextCleaned()) {
      widget.onNext();
    } else {
      return await showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: "ERROR",
            contents: [
              SizedBox(height: 20),
              Text("Please make sure every word is segmented correctly."),
              SizedBox(height: 20),
              Text(
                "Tip: Make sure every word has green background.",
                style: TextStyle(
                  color: Color(0xFFA3A3A3),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      );
    }
  }
}

// Use to interact with the segmented text and display dialog
class TextBox extends StatefulWidget {
  const TextBox({
    super.key,

    required this.index,
    required this.onMerge,
    required this.onSplit,
    required this.label,
    required this.isSegmented,
    required this.onFalseAlarm,
    required this.onRemove,
  });
  final String label;
  final bool isSegmented;
  final int index;
  final void Function(int, int) onMerge;
  final void Function(List<Characters>, int) onSplit;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onFalseAlarm;

  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  Color get boxColor =>
      widget.isSegmented ? Color(0xFFD2E9E6) : Color(0xFFFFCBCC);
  Color get invertBoxColor =>
      !widget.isSegmented ? Color(0xFFD2E9E6) : Color(0xFFFFCBCC);

  Future<void> onTap(BuildContext context) async {
    final result = await showDialog(
      barrierColor: Colors.black.withAlpha(51),
      context: context,
      builder: (context) {
        bool isSecondDialog = false;
        return StatefulBuilder(
          builder: (context, setState) {
            void setDialogState(bool value) {
              setState(() {
                isSecondDialog = value;
              });
            }

            return isSecondDialog
                ? FalseAlarmDialog(
                    setDialogState: setDialogState,
                    boxColor: boxColor,
                    widget: widget,
                    invertBoxColor: invertBoxColor,
                  )
                : ManualSegmentDialog(
                    setDialogState: setDialogState,
                    boxColor: boxColor,
                    label: widget.label,
                    isSegmented: widget.isSegmented,
                    index: widget.index,
                    invertBoxColor: invertBoxColor,
                  );
          },
        );
      },
    );
    if (result is List<Characters>) {
      if (result.isNotEmpty) {
        widget.onSplit(result, widget.index);
      } else {
        widget.onRemove(widget.index);
      }
    } else if (result is bool) {
      widget.onFalseAlarm(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        return (widget.index - details.data).abs() == 1;
      },
      onAcceptWithDetails: (details) {
        widget.onMerge(widget.index, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: widget.index,
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: SegmentedBox(boxColor: boxColor, label: widget.label),
          ),
          feedback: Material(
            color: Colors.transparent,
            child: SegmentedBox(
              boxColor: HSLColor.fromColor(
                boxColor,
              ).withLightness(0.6).toColor(),
              label: widget.label,
            ),
          ),
          child: GestureDetector(
            onTap: () => {onTap(context)},
            child: SegmentedBox(boxColor: boxColor, label: widget.label),
          ),
        );
      },
    );
  }
}

class ManualSegmentDialog extends StatefulWidget {
  const ManualSegmentDialog({
    super.key,
    required this.boxColor,

    required this.invertBoxColor,
    required this.setDialogState,
    required this.label,
    required this.isSegmented,
    required this.index,
  });

  final Color boxColor;
  final int index;
  final String label;
  final bool isSegmented;
  final Color invertBoxColor;
  final ValueChanged<bool> setDialogState;

  @override
  State<ManualSegmentDialog> createState() => _ManualSegmentDialogState();
}

class _ManualSegmentDialogState extends State<ManualSegmentDialog> {
  List<Characters> newSegmentedTexts = [];
  TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    newSegmentedTexts.add(Characters(widget.label));
    textFieldController.text = widget.label;
  }

  void onTextFieldChange(String value) {
    if (value.isNotEmpty) {
      Characters word = Characters(value);
      setState(() {
        newSegmentedTexts = word.split(' '.characters).toList();
      });
    } else {
      setState(() {
        newSegmentedTexts.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "Manual Segment",
      contents: [
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            text: "To manually segment the ",
            children: <TextSpan>[
              TextSpan(
                text: "Khmer text, ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "put a space between them. To "),
              TextSpan(
                text: "Edit",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " just write the new word in box."),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SegmentedBox(boxColor: widget.boxColor, label: widget.label),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: TextField(
            textAlignVertical: TextAlignVertical(y: -1),
            controller: textFieldController,
            onChanged: onTextFieldChange,
            expands: true,
            maxLength: null,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: TextStyle(fontFamily: "KantumruyPro"),
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 15,
            children: [
              if (textFieldController.text != widget.label)
                ...newSegmentedTexts.map(
                  (e) => SegmentedBox(
                    boxColor: widget.invertBoxColor,
                    label: e.toString(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 25,
          children: [
            if (!widget.isSegmented)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC6C6C6),
                  fixedSize: Size(113, 35),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  widget.setDialogState(true);
                },
                child: Text(
                  "False Alarm",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                if (textFieldController.text != widget.label) {
                  Navigator.pop(context, newSegmentedTexts);
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                fixedSize: Size(113, 35),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                "Confirm",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FalseAlarmDialog extends StatelessWidget {
  const FalseAlarmDialog({
    super.key,
    required this.boxColor,
    required this.widget,
    required this.invertBoxColor,
    required this.setDialogState,
  });

  final Color boxColor;
  final TextBox widget;
  final Color invertBoxColor;
  final ValueChanged<bool> setDialogState;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "False Alarm?",
      contents: [
        const SizedBox(height: 20),
        Text(
          "It seems the system is falsely identifying this term as a non-word. Please confirm the following action.",
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 15,
            children: [
              SegmentedBox(boxColor: boxColor, label: widget.label),
              Icon(Icons.arrow_right_alt),
              SegmentedBox(boxColor: invertBoxColor, label: widget.label),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "Note: This word will be saved to the dictionary to improve future text segmentation.",
          style: TextStyle(
            color: Color(0xFFA3A3A3),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 25,
          children: [
            if (!widget.isSegmented)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC6C6C6),
                  fixedSize: Size(113, 35),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  setDialogState(false);
                },
                child: Text(
                  "Back",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF808080),
                    fontSize: 13,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                fixedSize: Size(113, 35),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                "Confirm",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SegmentedBox extends StatelessWidget {
  const SegmentedBox({super.key, required this.boxColor, required this.label});

  final Color boxColor;
  final String label;

  String get text {
    if (label.length > 20) {
      return "${label.substring(0, 20)}...";
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(
          decoration: TextDecoration.none,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
