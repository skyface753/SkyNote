import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';

class InsertTopBar extends StatelessWidget {
  final ValueChanged<String> onCreateTextElement;
  final ValueChanged<String> onImagePaste;

  InsertTopBar({
    Key? key,
    required this.onCreateTextElement,
    required this.onImagePaste,
  }) : super(key: key);

  final TextEditingController newTextFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Create a TextField
        IconButton(
          icon: const Icon(Icons.text_fields),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Enter text'),
                  content: TextField(
                    autofocus: true,
                    onChanged: (String text) {
                      newTextFieldController.text = text;
                    },
                    onSubmitted: (value) {
                      onCreateTextElement(value);
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        onCreateTextElement(newTextFieldController.text);

                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        IconButton(
            icon: const Icon(Icons.paste),
            onPressed: () async {
              try {
                List<String> filePaths = await Pasteboard.files();
                print("Files");
                if (filePaths.isNotEmpty) {
                  print("files: ${filePaths.length}");
                  bool gotAnImage = false;
                  for (String filePath in filePaths) {
                    print(filePath);
                    if (filePath.endsWith(".png") ||
                        filePath.endsWith(".jpg")) {
                      gotAnImage = true;
                      onImagePaste(filePath);
                    }
                  }
                  if (!gotAnImage) {
                    showFlashTopBar(context, "No image found", false);
                  }
                } else {
                  showFlashTopBar(context, "No files found", false);
                }
              } catch (e) {
                print(e);
              }
            }),
      ],
    );
  }
}

void showFlashTopBar(BuildContext context, String text, bool success) {
  showFlash(
      context: context,
      duration: const Duration(seconds: 1, milliseconds: 500),
      builder: (_, controller) {
        return Flash(
            controller: controller,
            position: FlashPosition.top,
            behavior: FlashBehavior.floating,
            child: FlashBar(
              content: Text(text,
                  style: TextStyle(color: success ? Colors.green : Colors.red)),
            ));
      });
}
