// TOPBAR in Main

import 'package:appwrite/appwrite.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/main.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/note_book.dart';
import 'package:pasteboard/pasteboard.dart';

String _formsToString(Forms form) {
  switch (form) {
    case Forms.none:
      return 'Forms';
    case Forms.line:
      return 'line';
    case Forms.rectangle:
      return 'rectangle';
    case Forms.circle:
      return 'circle';
    case Forms.triangle:
      return 'triangle';
  }
}

class TopBar extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  List<PaintElement>? paintElements;
  List<Color> colorItems;
  List<Forms> formItems;
  Forms selectedForm;
  List<double> strokeWidthItems;
  Offset offset;
  Paint currentPaint;
  List<Background> backgroundItems;
  NoteBook noteBook;
  CanvasState canvasState;
  double currScale;
  Color selectedPaintColor;
  final ValueChanged<Color> onChangPaintColor;
  final ValueChanged<double> onChangeStrokeWidth;
  final ValueChanged<Forms> onChangeForm;
  final ValueChanged<Background> onChangeBackground;
  final VoidCallback onChangeEraseMode;
  final VoidCallback onChangeLassoMode;
  final VoidCallback onImagePicker;
  final VoidCallback onSave;
  final VoidCallback onVerify;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onGoToHome;
  final ValueChanged<String> onCreateTextElement;
  final ValueChanged<String> onImagePaste;

  TopBar(
    this.scaffoldKey,
    this.paintElements,
    this.colorItems,
    this.formItems,
    this.selectedForm,
    this.strokeWidthItems,
    this.offset,
    this.currentPaint,
    this.backgroundItems,
    this.noteBook,
    this.canvasState,
    this.currScale,
    this.selectedPaintColor, {
    Key? key,
    required this.onChangPaintColor,
    required this.onChangeStrokeWidth,
    required this.onChangeForm,
    required this.onChangeBackground,
    required this.onChangeEraseMode,
    required this.onChangeLassoMode,
    required this.onImagePicker,
    required this.onSave,
    required this.onVerify,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGoToHome,
    required this.onCreateTextElement,
    required this.onImagePaste,
  }) : super(key: key);

  Storage appwriteStorage = AppWriteCustom().getAppwriteStorage();
  TextEditingController newTextFieldController = TextEditingController();

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
                    style:
                        TextStyle(color: success ? Colors.green : Colors.red)),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    // print("TopBar build");
    // print(currentPaint.color.runtimeType);
    // print(colorItems.color.runtimeType);
    return Container(
      padding: const EdgeInsets.all(8),
      height: 70,
      width: double.infinity,
      color: Colors.grey,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              onPressed: () {
                if (paintElements!.isNotEmpty) {
                  paintElements!.removeLast();
                }
              },
            ),
            // Create a TextField
            IconButton(
              icon: const Icon(Icons.text_fields),
              color: Colors.black,
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
                            // paintElements!.add(
                            //   TextElement(
                            //     newTextFieldController.text,
                            //     offset,
                            //     currentPaint,
                            //   ),
                            // );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            DropdownButton(
              value: selectedPaintColor,
              items: colorItems.map(
                (color) {
                  return DropdownMenuItem(
                    value: color,
                    child: ColoredBox(
                      color: color,
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (Color? color) {
                onChangPaintColor(color!);
              },
            ), // Background
            DropdownButton(
                items: backgroundItems.map((background) {
                  return DropdownMenuItem(
                      value: background,
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child:
                            CustomPaint(painter: BackgroundPreview(background)),
                      ));
                }).toList(),
                value: noteBook.defaultBackground,
                onChanged: (Background? newValue) {
                  onChangeBackground(newValue!);
                }), // Background

            DropdownButton(
              value: currentPaint.strokeWidth,
              items: strokeWidthItems
                  .map(
                    (strokeWidth) => DropdownMenuItem(
                      value: strokeWidth,
                      child: Text(
                        '$strokeWidth',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (double? newValue) {
                onChangeStrokeWidth(newValue!);
              },
              dropdownColor: Colors.white,
            ),
            DropdownButton(
                items: formItems.map((form) {
                  return DropdownMenuItem(
                      value: form,
                      child: Text(
                        _formsToString(form),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      ));
                }).toList(),
                value: selectedForm,
                onChanged: (Forms? newValue) {
                  onChangeForm(newValue!);
                }),
            IconButton(
                icon: const Icon(Icons.paste),
                onPressed: () async {
                  // try {
                  //   final imageBytes = await Pasteboard.image;
                  //   print("Image");
                  //   print("imageBytes: ${imageBytes!.length}");

                  //   final tempDir = await getTemporaryDirectory();
                  //   File file =
                  //       await File('${tempDir.path}/image.png').create();
                  //   file.writeAsBytesSync(imageBytes);
                  //   onImagePaste(file.path);
                  // } catch (e) {
                  //   print(e);
                  // } catch (e) {
                  //   print(e);
                  // }
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
            // Eraser Button
            IconButton(
              icon: const Icon(Icons.delete),
              color:
                  CanvasState.erase == canvasState ? Colors.red : Colors.black,
              onPressed: () {
                onChangeEraseMode();
              },
            ),
            // Lasso Mode
            IconButton(
              icon: const Icon(Icons.line_axis),
              color:
                  CanvasState.lasso == canvasState ? Colors.red : Colors.black,
              onPressed: () {
                onChangeLassoMode();
              },
            ),
            IconButton(
                onPressed: () async {
                  onImagePicker();
                },
                icon: const Icon(Icons.add_photo_alternate)),
            //Save Button
            IconButton(
              icon: const Icon(Icons.save),
              color: Colors.black,
              onPressed: () {
                onSave();
                // saveToAppwrite;
              },
            ),
            //Verify Button
            IconButton(
              icon: const Icon(Icons.verified_user),
              color: Colors.black,
              onPressed: () {
                onVerify();
                // verifyNotebook;
              },
            ),
            // Zoom Button
            IconButton(
              icon: const Icon(Icons.zoom_in),
              color: Colors.black,
              onPressed: () {
                onZoomIn();
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              color: Colors.black,
              onPressed: () {
                onZoomOut();
              },
            ),
            // Back to Notebook List Screen

            IconButton(
              icon: const Icon(
                  Icons.logout), // Not sure if this is the right icon
              color: Colors.black,
              onPressed: () async {
                //TODO Show loading dialog while saving
                onGoToHome();
              },
            ),
          ],
        ),
      ),
    );
  }
}
