import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/segment.dart';
import 'package:khmer_text_vectorization/model/services/sample_persistence_service.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/model/tf_idf.dart';
import 'package:khmer_text_vectorization/ui/Screens/vectorize/vectorize_screen.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/data_labelling.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_dialog.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_future_builder.dart';
import 'package:khmer_text_vectorization/ui/widgets/custom_view_screen_widget.dart';
import 'package:khmer_text_vectorization/ui/widgets/loading_dialog.dart';
import 'package:khmer_text_vectorization/ui/widgets/segmented_box.dart';

class ViewSampleScreen extends StatefulWidget {
  const ViewSampleScreen({super.key, required this.selectedSample});
  final Sample selectedSample;

  @override
  State<ViewSampleScreen> createState() => _ViewSampleScreenState();
}

class _ViewSampleScreenState extends State<ViewSampleScreen> {
  late Sample selectedSample;
  @override
  void initState() {
    super.initState();
    selectedSample = widget.selectedSample;
  }

  void rebuilt() {
    setState(() {});
  }

  Future<void> onRefactorButtonPress() async {
    return await showDialog(
      context: context,
      builder: (context) {
        bool isProceed = false;
        return StatefulBuilder(
          builder: (context, setState) {
            void onProceedTap() async {
              setState(() {
                isProceed = true;
              });
              await SamplePersistenceService.instance.refactorGlobalIDF();

              if (context.mounted) {
                Navigator.pop(context);
              }
              rebuilt();
            }

            return !isProceed
                ? RefactorIDFDialog(onProceedTap: onProceedTap)
                : const LoadingDialog(
                    title: "Refactoring",
                    description: "Please wait until the operation is done.",
                  );
          },
        );
      },
    );
  }

  bool get needsRefactor => SamplePersistenceService.needsIDFRefactor;

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder<List<Segment>>(
      futureData: selectedSample.segmentedText,
      defaultValue: const [],
      builder: (context, segmentedText) {
        return CustomViewScreenWidget(
          title: "View Sample",
          crossAxisAlignment: CrossAxisAlignment.stretch,
          contents: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  Text(
                    selectedSample.name,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(selectedSample.description),
                  const SizedBox(height: 30),
                  const Text(
                    "STANCE LABEL",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 11),
                  CustomBinaryRadioMenu(
                    selectedStance: selectedSample.stanceLabel,
                    onStanceTap: (value) {},
                  ),
                  const SizedBox(height: 30),

                  // --- Topic Tags ---
                  const Text(
                    "TOPIC TAGS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 11),
                  Container(
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
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...(selectedSample.topicTags ?? []).map(
                          (e) => CustomTopicChip(
                            label: e.tagName,
                            onRemove: (value) {},
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFD2E9E6),
                          ),
                          width: 25,
                          height: 25,
                          child: const Icon(Icons.add, size: 15),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Raw Text ---
                  const Text(
                    "Raw Text",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    constraints: BoxConstraints(maxHeight: 419),
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
                      child: Text(
                        selectedSample.originalInput,
                        style: const TextStyle(fontFamily: "KantumruyPro"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Segmented Text ---
                  const Text(
                    "Segmented Text",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 11),
                  Text("Total Words: ${segmentedText.length}"),
                  const SizedBox(height: 11),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 173),
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
                        spacing: 10,
                        runSpacing: 10,
                        children: segmentedText
                            .map((e) => SegmentedBox(label: e.text.string))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TF-IDF
                  const Text(
                    "TF-IDF Vector",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 11),
                  CustomFutureBuilder<Map<int, TfIdf>>(
                    futureData: selectedSample.tfIdfVector,
                    defaultValue: {},
                    builder: (context, tfIdfVector) {
                      return Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                    "Word",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                    "Frequency (TF)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                    "Significance (IDF)",

                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                    "Vector Score",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ...tfIdfVector.entries.map(
                            (e) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      (segmentedText.firstWhere(
                                        (eT) => eT.id == e.key,
                                      )).text.string,
                                      style: const TextStyle(
                                        fontFamily: "KantumruyPro",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      e.value.tf.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      e.value.idf.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      e.value.score.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      fixedSize: const Size(130, 35),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () async {
                      Sample updatedSample =
                          await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CustomViewScreenWidget(
                                      title: "Edit Sample",
                                      contents: [
                                        Expanded(
                                          child: VectorizeScreen.edit(
                                            editSample: selectedSample,
                                            editSegmentedText: segmentedText,
                                          ),
                                        ),
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                    );
                                  },
                                ),
                              )
                              as Sample;
                      setState(() {
                        selectedSample = updatedSample;
                      });
                    },
                    child: const Text(
                      "Edit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      fixedSize: Size(130, 35),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),

                    onPressed: needsRefactor ? onRefactorButtonPress : null,
                    child: const Text(
                      "Refactor the IDF",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class RefactorIDFDialog extends StatelessWidget {
  const RefactorIDFDialog({super.key, required this.onProceedTap});

  final VoidCallback onProceedTap;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "Refactoring IDF",
      contents: [
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            text:
                "This process may take several moments to synchronize based on your current dictionary volume.",
            children: [
              TextSpan(
                text:
                    "\nDictionary Word Count: ${SegmentingService.instance.dictionary.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            fixedSize: Size(130, 35),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: onProceedTap,
          child: const Text("Proceed"),
        ),
      ],
    );
  }
}
