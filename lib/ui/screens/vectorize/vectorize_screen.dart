import 'dart:math';

import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/model/segment.dart';
import 'package:khmer_text_vectorization/model/services/quality_assess_service.dart';
import 'package:khmer_text_vectorization/model/services/sample_persistence_service.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/almost_there.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/data_labelling.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/kh_text_input.dart';
import 'package:khmer_text_vectorization/ui/screens/vectorize/segmentation.dart';
import 'package:khmer_text_vectorization/ui/widgets/navigation.dart';

class VectorizeScreen extends StatefulWidget {
  const VectorizeScreen({
    super.key,
    this.switchTab,
    this.editSample,
    this.editSegmentedText,
  });
  const VectorizeScreen.edit({
    super.key,
    required this.editSample,
    required this.editSegmentedText,
    this.switchTab,
  });
  final ValueChanged<ScreenType>? switchTab;
  final Sample? editSample;
  final List<Segment>? editSegmentedText;

  @override
  State<VectorizeScreen> createState() => _VectorizeScreenState();
}

class _VectorizeScreenState extends State<VectorizeScreen> {
  int currentStep = 0;
  String currentRawText = "";
  List<Segment> segmentedText = [];
  bool? stanceLabel;
  Set<TopicTag> topicTags = {};
  double score = 0;

  UniqueKey key = UniqueKey();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editSample != null && widget.editSegmentedText != null) {
      currentRawText = widget.editSample!.originalInput;
      segmentedText = [...widget.editSegmentedText!];
      stanceLabel = widget.editSample!.stanceLabel;
      topicTags = {...(widget.editSample!.topicTags ?? []).toSet()};
      score = widget.editSample!.quality;
      nameController.text = widget.editSample!.name;
      descriptionController.text = widget.editSample!.description;
    }
  }

  Future<void> onVectorize(
    BuildContext dialogContext,
    BuildContext parentContext,
  ) async {
    final startTime = DateTime.now();

    Sample savedSample = await SamplePersistenceService.instance.saveSample(
      editSample: widget.editSample,
      name: nameController.text,
      description: descriptionController.text,
      rawText: currentRawText,
      stanceLabel: stanceLabel,
      quality: score,
      topicTags: topicTags,
      segmentedText: segmentedText,
    );

    final elapsed = DateTime.now().difference(startTime);
    const minimumwait = Duration(milliseconds: 1500);

    if (elapsed < minimumwait) {
      await Future.delayed(minimumwait - elapsed);
    }

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
      if (widget.switchTab != null) {
        widget.switchTab!(ScreenType.collection);
      }
    }
    if (widget.switchTab != null) {
      resetStepper();
    } else {
      if (parentContext.mounted) {
        Navigator.pop(parentContext, savedSample);
      }
    }
  }

  void resetStepper() {
    setState(() {
      key = UniqueKey();

      currentStep = 0;

      nameController.clear();
      descriptionController.clear();

      topicTags.clear();
      stanceLabel = null;
      segmentedText = [];
      currentRawText = "";
    });
  }

  void updateStance(bool value) {
    stanceLabel = value;
  }

  void updateTopicTags(Set<TopicTag> newTopicTags) {
    topicTags = newTopicTags;
  }

  void updateSegmentedText(List<Segment> newList) {
    segmentedText = newList;
  }

  void onTextInputNext(String rawText) async {
    if (currentRawText != rawText) {
      currentRawText = rawText;
    } else {
      onNext();
      return;
    }
    final updatedSegmentedText = await SegmentingService.instance
        .segmentRawText(currentRawText);

    segmentedText = updatedSegmentedText;

    onNext();
  }

  void onDataLabellingNext() {
    // SetState because AlmostThere widget is stateless (Parent need to rebuilt)
    setState(() {
      score = QualityAssessService.instance.assessInput(
        segmentedText.map((e) => e.text).toList(),
        stanceLabel,
        topicTags,
      );
    });

    onNext();
  }

  void onNext() {
    setState(() {
      currentStep++;
    });
  }

  void onBack() {
    setState(() {
      currentStep = max(currentStep - 1, 0);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          // --- CUSTOM STEPPER HEADER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStepNode(0, "Text Input"),
                    _buildConnector(0),
                    _buildStepNode(1, "Segmentation"),
                    _buildConnector(1),
                    _buildStepNode(2, "Data Labelling"),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
            color: Colors.black,
            width: double.infinity,
            height: 2,
          ),

          // --- CONTENT AREA ---
          Expanded(
            child: IndexedStack(
              key: key,
              index: currentStep,
              children: [
                KHTextInput(onNext: onTextInputNext, initValue: currentRawText),
                Segmentation(
                  segmentedText: segmentedText,
                  onBack: onBack,
                  onNext: onNext,
                  updateSegmentedText: updateSegmentedText,
                ),
                DataLabelling(
                  onBack: onBack,
                  onNext: onDataLabellingNext,
                  updateStance: updateStance,
                  updateTags: updateTopicTags,
                  initStance: stanceLabel,
                  initTopicTags: topicTags,
                ),
                AlmostThere(
                  quality: score,
                  nameController: nameController,
                  descriptionController: descriptionController,
                  onBack: onBack,
                  parentContext: context,
                  onVectorize: onVectorize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index, String label) {
    bool isCompleted = currentStep > index;
    bool isActive = currentStep == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        if (widget.editSample != null) {
          currentStep = index;
        }
      }),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.white,
              border: Border.all(
                color: (isCompleted || isActive)
                    ? Colors.green
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : isActive
                ? Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int index) {
    bool isFinished = currentStep > index;
    return Expanded(
      child: Padding(
        // The bottom padding ensures the line aligns with the center of the circle
        padding: const EdgeInsets.only(bottom: 25),
        child: Container(
          height: 1,
          color: isFinished ? Colors.green : Colors.grey.shade300,
        ),
      ),
    );
  }
}
