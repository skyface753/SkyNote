import 'package:flutter/material.dart';
import 'package:skynote/main.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/note_book.dart';

class StartTopBar extends StatelessWidget {
  final CanvasState canvasState;
  final List<PaintElement>? paintElements;
  final List<Background> backgroundItems;
  final VoidCallback onGoToHome;
  final NoteBook noteBook;
  final SelectionModes currentSelectionMode;
  final bool darkMode;
  final ValueChanged<Background> onChangeBackground;
  final ValueChanged<SelectionModes> onChangeSelectionMode;
  final VoidCallback onImagePicker;
  final VoidCallback onSave;
  final VoidCallback onVerify;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onDarkModeSwitch;

  const StartTopBar(
      {Key? key,
      required this.canvasState,
      required this.paintElements,
      required this.backgroundItems,
      required this.onGoToHome,
      required this.noteBook,
      required this.currentSelectionMode,
      required this.darkMode,
      required this.onChangeBackground,
      required this.onChangeSelectionMode,
      required this.onImagePicker,
      required this.onSave,
      required this.onVerify,
      required this.onZoomIn,
      required this.onZoomOut,
      required this.onDarkModeSwitch})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.logout), // Not sure if this is the right icon
          // color: Colors.black,
          onPressed: () async {
            //TODO Show loading dialog while saving
            onGoToHome();
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          // color: Colors.black,
          onPressed: () {
            //TODO Void callback
            if (paintElements!.isNotEmpty) {
              paintElements!.removeLast();
            }
          },
        ),
        // Background
        DropdownButton(
            items: backgroundItems.map((background) {
              return DropdownMenuItem(
                  value: background,
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CustomPaint(painter: BackgroundPreview(background)),
                  ));
            }).toList(),
            value: noteBook.selectedSectionIndex != null &&
                    noteBook.selectedNoteIndex != null
                ? noteBook.sections[noteBook.selectedSectionIndex!]
                    .notes[noteBook.selectedNoteIndex!].background
                : Background.none,
            onChanged: (Background? newValue) {
              onChangeBackground(newValue!);
            }), // Background
        IconButton(
          onPressed: () {
            onDarkModeSwitch();
          },
          icon: Icon(Icons.dark_mode),
          color: darkMode ? Colors.yellow : Colors.white,
        ),
// Selection Mode
        DropdownButton(
            items: [
              DropdownMenuItem(
                value: SelectionModes.rect,
                child: Text('Rect'),
              ),
              DropdownMenuItem(
                value: SelectionModes.lasso,
                child: Text('Lasso'),
              ),
            ],
            value: currentSelectionMode,
            onChanged: (SelectionModes? newValue) {
              onChangeSelectionMode(newValue!);
            }),

        // IconButton(
        //   icon: const Icon(Icons.line_axis),
        //   color: CanvasState.select == canvasState
        //       ? Colors.red
        //       : Colors.black,
        //   onPressed: () {
        //     onChangeLassoMode();
        //   },
        // ),
        IconButton(
            onPressed: () async {
              onImagePicker();
            },
            icon: const Icon(Icons.add_photo_alternate)),
        //Save Button
        IconButton(
          icon: const Icon(Icons.save),
          // color: Colors.black,
          onPressed: () {
            onSave();
            // saveToAppwrite;
          },
        ),
        //Verify Button
        IconButton(
          icon: const Icon(Icons.verified_user),
          // color: Colors.black,
          onPressed: () {
            onVerify();
            // verifyNotebook;
          },
        ),

        // Zoom Button
        IconButton(
          icon: const Icon(Icons.zoom_in),
          // color: Colors.black,
          onPressed: () {
            onZoomIn();
          },
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          // color: Colors.black,
          onPressed: () {
            onZoomOut();
          },
        ),
      ],
    );
  }
}

class BackgroundPreview extends CustomPainter {
  Background background;
  BackgroundPreview(this.background);
  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()..color = Colors.white.withOpacity(1);
    if (background == Background.none) {
      return;
    } else if (background == Background.checkered) {
      for (int i = 0; i < size.width; i += 10) {
        canvas.drawLine(Offset(i.toDouble(), 0),
            Offset(i.toDouble(), size.height), backgroundPaint);
      }
      for (int i = 0; i < size.height; i += 10) {
        canvas.drawLine(Offset(0, i.toDouble()),
            Offset(size.width, i.toDouble()), backgroundPaint);
      }
    } else if (background == Background.lines) {
      for (int i = 0; i < size.height; i += 10) {
        canvas.drawLine(Offset(0, i.toDouble()),
            Offset(size.width, i.toDouble()), backgroundPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPreview oldDelegate) {
    return false;
  }
}
