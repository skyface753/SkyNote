// TOPBAR in Main

import 'dart:io';
import 'package:appwrite/appwrite.dart';

import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/main.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/note_book.dart';
import 'package:skynote/models/paint_image.dart';

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
  final ValueChanged<Color> onChangPaintColor;
  final ValueChanged<double> onChangeStrokeWidth;
  final ValueChanged<Forms> onChangeForm;
  final ValueChanged<Background> onChangeBackground;
  final VoidCallback onChangeEraseMode;
  final VoidCallback onImagePicker;
  final VoidCallback onSave;
  final VoidCallback onVerify;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onGoToHome;

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
    this.currScale, {
    required this.onChangPaintColor,
    required this.onChangeStrokeWidth,
    required this.onChangeForm,
    required this.onChangeBackground,
    required this.onChangeEraseMode,
    required this.onImagePicker,
    required this.onSave,
    required this.onVerify,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGoToHome,
  });

  Storage appwriteStorage = AppWriteCustom().getAppwriteStorage();

  @override
  Widget build(BuildContext context) {
    // print("TopBar build");
    // print(currentPaint.color);
    // print(colorItems);
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
            DropdownButton(
              value: currentPaint.color,
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
            // Eraser Button
            IconButton(
              icon: const Icon(Icons.delete),
              color:
                  CanvasState.erase == canvasState ? Colors.red : Colors.black,
              onPressed: () {
                onChangeEraseMode();
              },
            ), //Add an Image
            //TODO
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
