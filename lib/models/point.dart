import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skynote/helpers/paint_convert.dart';
import 'package:skynote/helpers/paint_convert_by_dark_mode.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/selections/lasso_selection.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

var paintConverter = PaintConverter();

class Point extends PaintElement {
  double x;
  double y;
  bool isRenderd = false;
  Point(this.x, this.y, Paint paint) : super(paint);

  void draw(Canvas canvas, Offset offset, double width, double height,
      bool isDarkMode) {
    if (-offset.dx <= x &&
        x <= -offset.dx + width &&
        -offset.dy <= y &&
        y <= -offset.dy + height) {
      paintConvertByDark(isDarkMode, paint, () {
        canvas.drawPoints(
            PointMode.points, [Offset(x + offset.dx, y + offset.dy)], paint);
        // print("Drawing point");
      });
      isRenderd = true;
    } else {
      // print("Not drawing point");
      isRenderd = false;
    }
  }

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool isDarkMode,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    bool isInBounds = -offset.dx <= x &&
        x <= -offset.dx + width &&
        -offset.dy <= y &&
        y <= -offset.dy + height;
    if (isInBounds) {
      isRenderd = true;
      return CustomPaint(
        painter: PointPainter(this, offset, width, height, isDarkMode),
      );
    } else {
      isRenderd = false;
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.point.index,
      'x': x,
      'y': y,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  Point.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'],
        super(paintConverter.paintFromJson(json['paint']));

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    if (!isRenderd) {
      return false;
    }
    int testWidth = 5;
    int xAddPlus = (x + testWidth).toInt();
    int xAddMinus = (x - testWidth).toInt();
    int yAddPlus = (y + testWidth).toInt();
    int yAddMinus = (y - testWidth).toInt();

    if (lineEraser.a.x < xAddPlus &&
        lineEraser.a.x > xAddMinus &&
        lineEraser.a.y < yAddPlus &&
        lineEraser.a.y > yAddMinus) {
      print("Point intersects in A segment");
      return true;
    }
    if (lineEraser.b.x < xAddPlus &&
        lineEraser.b.x > xAddMinus &&
        lineEraser.b.y < yAddPlus &&
        lineEraser.b.y > yAddMinus) {
      print("Point intersects in B segment");
      return true;
    }
    return false;
  }

  @override
  bool checkSelection(SelectionBase selection) {
    if (!isRenderd) {
      return false;
    }
    if (selection.checkCollision(vm.Vector2(x, y))) {
      return true;
    }
    return false;
  }

  @override
  double getBottomY() {
    return y;
  }

  @override
  double getLeftX() {
    return x;
  }

  @override
  double getRightX() {
    return x;
  }

  @override
  double getTopY() {
    return y;
  }

  @override
  void moveByOffset(Offset offset) {
    x += offset.dx;
    y += offset.dy;
  }
}

class PointPainter extends CustomPainter {
  Point point;
  Offset offset;
  double width;
  double height;

  bool isDarkMode;
  PointPainter(
      this.point, this.offset, this.width, this.height, this.isDarkMode);
  @override
  void paint(Canvas canvas, Size size) {
    point.draw(canvas, offset, width, height, isDarkMode);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
