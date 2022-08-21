import 'package:flutter/material.dart';
import 'package:skynote/helpers/paint_convert_by_dark_mode.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class RectSelection extends SelectionBase {
  vm.Vector2? endPoint;

  RectSelection(vm.Vector2 startPoint) : super(startPoint);

  @override
  bool checkCollision(vm.Vector2 otherPoint) {
    if (endPoint == null) {
      print("RectSelection checkCollision endPoint == null");
      return false;
    }
    if (_isBetween(otherPoint.x, startPoint.x, endPoint!.x) &&
        _isBetween(otherPoint.y, startPoint.y, endPoint!.y)) {
      print("RectSelection checkCollision true");
      return true;
    }
    print("RectSelection checkCollision false");
    return false;
  }

  @override
  void drawCurrent(Canvas canvas, Offset offset, double width, double height,
      bool isDarkMode) {
    if (endPoint == null) {
      return;
    }
    Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 4;
    paintConvertByDark(isDarkMode, paint, () {
      canvas.drawRect(
          Rect.fromLTRB(startPoint.x + offset.dx, startPoint.y + offset.dy,
              endPoint!.x + offset.dx, endPoint!.y + offset.dy),
          paint);
    });
  }

  @override
  void setPoint(vm.Vector2 point) {
    endPoint = point;
  }
}

bool _isBetween(double chechValue, double value1, double value2) {
  if (value1 > value2) {
    return chechValue > value2 && chechValue < value1;
  } else {
    return chechValue > value1 && chechValue < value2;
  }
}
