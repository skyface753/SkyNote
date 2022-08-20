import 'package:flutter/material.dart';
import 'package:skynote/models/forms/arrow.dart';
import 'package:skynote/models/forms/arrow_double.dart';
import 'package:skynote/models/forms/circle.dart';
import 'package:skynote/models/forms/rect.dart';
import 'package:skynote/models/forms/triangle.dart';
import 'package:skynote/models/line.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/forms/line.dart';
import 'package:skynote/models/paint_image.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:skynote/models/text.dart';
import 'package:skynote/models/types.dart';

abstract class PaintElement {
  Paint paint;
  // TODO
  // bool isRenderd = false;
  PaintElement(Paint currpaint)
      : paint = Paint()
          ..color = currpaint.color
          ..strokeWidth = currpaint.strokeWidth
          ..style = currpaint.style
          ..strokeCap = currpaint.strokeCap;

  Widget? build(
    BuildContext context,
    Offset offset,
    double width,
    double height,
    bool isDarkMode,
    VoidCallback refreshFromElement,
    ValueChanged<String> onDeleteImage,
  );

  bool intersectAsSegments(LineEraser lineEraser);
  bool checkSelection(SelectionBase selection);
  Map<String, dynamic> toJson();
  void setStrokeWidth(double width) {
    paint.strokeWidth = width;
  }

  void setColor(Color color) {
    paint.color = color;
  }

  double getLeftX();
  double getRightX();
  double getTopY();
  double getBottomY();

  void moveByOffset(Offset offset);

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
      } else if (e['type'] == PaintElementTypes.rectForm.index) {
        return RectForm.fromJson(e);
      } else if (e['type'] == PaintElementTypes.circleForm.index) {
        return CircleForm.fromJson(e);
      } else if (e['type'] == PaintElementTypes.triangleForm.index) {
        return TriangleForm.fromJson(e);
      } else if (e['type'] == PaintElementTypes.arrowForm.index) {
        return ArrowForm.fromJson(e);
      } else if (e['type'] == PaintElementTypes.arrowDoubleForm.index) {
        return ArrowDoubleForm.fromJson(e);
      } else {
        throw Exception('Unknown type: ${e['type']}');
      }
    }).toList();
  }

  static List<Widget> buildWidgets(
    bool shouldRender,
    BuildContext context,
    List<PaintElement> paintElements,
    Offset offset,
    bool isDarkMode, {
    required VoidCallback refreshFromElement,
    required ValueChanged<String> onDeleteImage,
  }) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<Widget> widgets = [];
    if (!shouldRender) {
      return widgets;
    }
    for (PaintElement paintElement in paintElements) {
      Widget? widget = paintElement.build(context, offset, width, height,
          isDarkMode, refreshFromElement, onDeleteImage);
      if (widget != null) {
        widgets.add(widget);
      }
    }
    return widgets;
  }
}
