import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:khmer_text_vectorization/model/services/export_import_service.dart';
import 'package:khmer_text_vectorization/model/services/segmenting_service.dart';
import 'package:khmer_text_vectorization/ui/screens/dictionary.dart';
import 'package:khmer_text_vectorization/ui/widgets/pop_up.dart';
import 'package:material_symbols_icons/symbols.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, required this.list, required this.refreshData});
  final VoidCallback refreshData;

  final Map<Characters, int> list;

  void resetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Popup(
        title: "Reset to default",
        content: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ), // Default style
                children: [
                  const TextSpan(text: "The following action will "),
                  TextSpan(
                    text: "reset the entire app",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  const TextSpan(text: " into its "),
                  const TextSpan(
                    text: "freshly downloaded version.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
            onPressed: () async {
              await ExportImportService.resetDictionary();
              await SegmentingService.instance.initDictionary();
              if (context.mounted) {
                Navigator.pop(context);
              }
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
            onPressed: () async {
              await ExportImportService.exportDictionary();
              if (context.mounted) {
                Navigator.pop(context);
              }
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
      builder: (_) => ImportDictionaryDialog(refreshData: refreshData),
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
                        builder: (context) =>
                            Dictionary(list: list, refreshData: refreshData),
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

class ImportDictionaryDialog extends StatefulWidget {
  const ImportDictionaryDialog({super.key, required this.refreshData});

  final VoidCallback refreshData;

  @override
  State<ImportDictionaryDialog> createState() => _ImportDictionaryDialogState();
}

class _ImportDictionaryDialogState extends State<ImportDictionaryDialog> {
  FilePickerResult? result;
  @override
  Widget build(BuildContext context) {
    return Popup(
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
            onPressed: () async {
              FilePickerResult? temp = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['txt'],
              );

              if (temp == null) return;

              setState(() {
                result = temp;
              });
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
            ),

            label: Text(
              result != null ? result!.files.single.name : "Select file",
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
          onPressed: result != null
              ? () async {
                  await ExportImportService.importDictionary(result!);
                  await SegmentingService.instance.initDictionary();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  widget.refreshData();
                }
              : null,
          child: const Text(
            "Confirm",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
