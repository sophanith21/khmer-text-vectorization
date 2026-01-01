import 'dart:math';

import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/sample.dart';
import 'package:khmer_text_vectorization/ui/widgets/filterDate.dart';
import 'package:khmer_text_vectorization/ui/widgets/circle_graph.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.allSamples});

  final List<Sample> allSamples;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime pickDate = DateTime.now();

  Future<void> datepicker(BuildContext context) async {
    final DateTime? dateSelected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: pickDate,
    );

    if (dateSelected != null && dateSelected != pickDate) {
      setState(() {
        pickDate = dateSelected;
      });
    }
  }

  void onDateChanges(bool isNext) {
    setState(() {
      if (isNext) {
        final newDate = pickDate.add(Duration(days: 1));

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final compareDate = DateTime(newDate.year, newDate.month, newDate.day);
        if (!compareDate.isAfter(today)) {
          pickDate = pickDate.add(Duration(days: 1));
        }
      } else {
        pickDate = pickDate.subtract(Duration(days: 1));
      }
    });
  }

  void onView() {
    //Todo: to view details
  }

  @override
  Widget build(BuildContext context) {
    double calcAvgQuality() {
      double sum = 0;
      int amount = 0;

      for (var sample in widget.allSamples) {
        sum += sample.quality;
        amount++;
      }
      amount = max(amount, 1);

      return sum / amount;
    }

    int allVecText = widget.allSamples.length;
    double allPercentage = calcAvgQuality();
    double allPercentageValue = calcAvgQuality() / 100;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          spacing: 30,
          children: [
            const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      allVecText.toString(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Texts\nVectorized",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                CircleGraph(
                  allPercentageValue: allPercentageValue,
                  allPercentage: allPercentage,
                  size: 150,
                  isShowText: true,
                ),
              ],
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => onDateChanges(false),
                            icon: const Icon(Icons.arrow_back_ios),
                          ),

                          SizedBox(
                            child: OutlinedButton(
                              onPressed: () => datepicker(context),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined),
                                  SizedBox(width: 10),
                                  Text(
                                    pickDate.toString().split(" ")[0],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () => onDateChanges(true),
                            icon: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                    ),

                    const Text(
                      "Text Vectorized",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Filterdate(
                      allSamples: widget.allSamples,
                      dateGroup: pickDate,
                      onView: onView,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
