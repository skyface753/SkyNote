import 'package:flutter/material.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class LassoSelection extends SelectionBase {
  List<vm.Vector2> lassoPoints = [];

  LassoSelection(vm.Vector2 startPoint) : super(startPoint);

  @override
  void setPoint(vm.Vector2 point) {
    lassoPoints.add(point);
  }

  bool _trianglePointCollsion(
      vm.Vector2 a, vm.Vector2 b, vm.Vector2 c, vm.Vector2 p) {
    double areaOrig =
        ((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)).abs();

    double areaABP =
        ((a.x - p.x) * (b.y - p.y) - (b.x - p.x) * (a.y - p.y)).abs();
    double areaBCP =
        ((b.x - p.x) * (c.y - p.y) - (c.x - p.x) * (b.y - p.y)).abs();
    double areaCAP =
        ((c.x - p.x) * (a.y - p.y) - (a.x - p.x) * (c.y - p.y)).abs();

    double area = areaABP + areaBCP + areaCAP;
    return area == areaOrig;
  }

  @override
  bool checkCollision(vm.Vector2 otherPoint) {
    // var startPoint = lassoPoints.first;
    for (int i = 1; i < lassoPoints.length; i++) {
      var currentPoint = lassoPoints[i];
      var lastPoint = lassoPoints[i - 1];
      if (_trianglePointCollsion(
          startPoint, lastPoint, currentPoint, otherPoint)) {
        print("Point in triangle");
        return true;
      }
    }
    print("Point not in triangle");
    return false;
  }

  @override
  void drawCurrent(Canvas canvas, Offset offset, double width, double height) {
    if (lassoPoints.isEmpty) {
      return;
    }
    for (int i = 1; i < lassoPoints.length; i++) {
      var currentPoint = lassoPoints[i];
      var lastPoint = lassoPoints[i - 1];
      canvas.drawLine(
          Offset(lastPoint.x + offset.dx, lastPoint.y + offset.dy),
          Offset(currentPoint.x + offset.dx, currentPoint.y + offset.dy),
          Paint()
            ..color = Colors.black.withOpacity(0.5)
            ..strokeWidth = 1
            ..strokeCap = StrokeCap.round);
    }
    canvas.drawLine(
        Offset(startPoint.x + offset.dx, startPoint.y + offset.dy),
        Offset(lassoPoints.last.x + offset.dx, lassoPoints.last.y + offset.dy),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1);
  }
}
