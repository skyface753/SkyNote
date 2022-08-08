import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skynote/models/line.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/line_form.dart';
import 'package:skynote/models/line_fragment.dart';
// import 'package:skynote/models/line_old.dart';
import 'package:skynote/models/paint_image.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/text.dart';
import 'package:skynote/models/types.dart';

abstract class PaintElement {
  Paint paint;
  PaintElement(Paint currpaint)
      : paint = Paint()
          ..color = currpaint.color
          ..strokeWidth = currpaint.strokeWidth
          ..style = currpaint.style
          ..strokeCap = currpaint.strokeCap;

  // void draw(Canvas canvas, Offset offset, double width, double height);
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool disableGestureDetection,
      VoidCallback refreshFromElement);
  bool intersectAsSegments(LineEraser lineEraser);

  Map<String, dynamic> toJson();

  // From Json
  static List<PaintElement> fromJson(
      List<dynamic> json, VoidCallback imageLoadCallback) {
    return json.map((e) {
      if (e['type'] == PaintElementTypes.point.index) {
        return Point.fromJson(e);
      } else if (e['type'] == PaintElementTypes.line.index) {
        return Line.fromJson(e);
      } else if (e['type'] == PaintElementTypes.lineForm.index) {
        return LineForm.fromJson(e);
      } else if (e['type'] == PaintElementTypes.paintImage.index) {
        return PaintImage.fromJson(e, imageLoadCallback);
      } else if (e['type'] == PaintElementTypes.textElement.index) {
        return TextElement.fromJson(e);
      } else {
        throw Exception('Unknown type: ${e['type']}');
      }
    }).toList();
  }

  static List<Widget> buildWidgets(
    BuildContext context,
    List<PaintElement> paintElements,
    Offset offset,
    bool disableGestureDetection, {
    required VoidCallback refreshFromElement,
  }) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<Widget> widgets = [];

    for (PaintElement paintElement in paintElements) {
      Widget? widget = paintElement.build(context, offset, width, height,
          disableGestureDetection, refreshFromElement);
      if (widget != null) {
        widgets.add(widget);
      }
    }
    return widgets;
  }
}
