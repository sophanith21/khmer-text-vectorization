import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/ui/screens/dictionary.dart';
import 'package:khmer_text_vectorization/ui/widgets/pop_up.dart';
import 'package:material_symbols_icons/symbols.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, required this.list});

  final Set<Characters> list;

  void resetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Popup(
        title: "Reset to default",
        content: Column(
          children: [
            const Text(
              "The following action wil reset the Dictionary into its freshly downloaded version.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 50),
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
              //todo: reset dictionary
              Navigator.pop(context);
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

  void exportDictionaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Popup(
        title: "Export",
        content: Column(
          children: [
            const Text(
              "Do you want export the current dictionary from our application?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 50),
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
              //todo: export dictionary
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

  void importDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Popup(
        title: "Export",
        content: Column(
          children: [
            const Text(
              "Select the file (.txt)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                //todo: pick file
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
              ),

              label: const Text(
                "Select file",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              icon: const Icon(
                Symbols.files_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF666666)),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //todo import filet);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            const Text(
              "Dictionary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border.all(color: Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Dictionary(list: list),
                      ),
                    ),
                    leading: const Icon(
                      Symbols.book_ribbon_rounded,
                      fontWeight: FontWeight.bold,
                    ),
                    title: const Text(
                      "View dictionary",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      exportDictionaryDialog(context);
                    },
                    leading: const Icon(
                      Symbols.file_export_rounded,
                      fontWeight: FontWeight.bold,
                    ),
                    title: const Text(
                      "Export the dictionary",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      importDialog(context);
                    },
                    leading: const Icon(
                      Symbols.add_ad_rounded,
                      fontWeight: FontWeight.bold,
                    ),
                    title: const Text(
                      "Import the dictionary",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      resetDialog(context);
                    },
                    leading: const Icon(
                      Symbols.reset_wrench_rounded,
                      fontWeight: FontWeight.bold,
                    ),
                    title: const Text(
                      "Reset to default",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Support & about",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border.all(color: Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text(
                      "App Version",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      "1.0.0",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.error_outline),
                    title: Text(
                      "Terms of Service",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline_rounded),
                    title: Text(
                      "About",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
