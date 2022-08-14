import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skynote/main.dart';

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
    case Forms.arrow:
      return 'arrow';
  }
}

class DrawTopBar extends StatelessWidget {
  final CanvasState canvasState;
  final Color selectedPaintColor;
  final List<Color> colorItems;
  final Paint currentPaint;
  final List<double> strokeWidthItems;
  final List<Forms> formItems;
  final Forms selectedForm;
  final VoidCallback onChangeEraseMode;
  final ValueChanged<Color> onChangPaintColor;
  final ValueChanged<double> onChangeStrokeWidth;
  final ValueChanged<Forms> onChangeForm;

  DrawTopBar(
    this.canvasState,
    this.selectedPaintColor,
    this.colorItems,
    this.currentPaint,
    this.strokeWidthItems,
    this.formItems,
    this.selectedForm,
    this.onChangeEraseMode,
    this.onChangPaintColor,
    this.onChangeStrokeWidth,
    this.onChangeForm,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Eraser Button
        IconButton(
          icon: const Icon(Icons.delete),
          color: CanvasState.erase == canvasState ? Colors.red : Colors.black,
          onPressed: () {
            onChangeEraseMode();
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
        ),
        DropdownButton(
          value: currentPaint.strokeWidth,
          items: strokeWidthItems
              .map(
                (strokeWidth) => DropdownMenuItem(
                    value: strokeWidth,
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(
                            child: CustomPaint(
                                painter: StrokeWidthPreview(strokeWidth))))
                    // Text(
                    //   '$strokeWidth',
                    //   style:
                    //       const TextStyle(fontSize: 20, color: Colors.black),
                    // ),
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
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ));
            }).toList(),
            value: selectedForm,
            onChanged: (Forms? newValue) {
              onChangeForm(newValue!);
            }),
      ],
    );
  }
}

class StrokeWidthPreview extends CustomPainter {
  final double strokeWidth;
  StrokeWidthPreview(this.strokeWidth);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, [const Offset(0, 0)], paint);
  }

  @override
  bool shouldRepaint(StrokeWidthPreview oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth;
  }
}
