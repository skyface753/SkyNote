import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class LassoSelection {
  vm.Vector2 startPoint;
  List<vm.Vector2> lassoPoints = [];

  LassoSelection(this.startPoint);

  void addLassoPoint(vm.Vector2 point) {
    lassoPoints.add(point);
  }

  bool trianglePointCollsion(
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

  bool checkCollision(vm.Vector2 otherPoint) {
    // var startPoint = lassoPoints.first;
    for (int i = 1; i < lassoPoints.length; i++) {
      var currentPoint = lassoPoints[i];
      var lastPoint = lassoPoints[i - 1];
      if (trianglePointCollsion(
          startPoint, lastPoint, currentPoint, otherPoint)) {
        return true;
      }
    }
    return false;
  }

  void drawCurrent(Canvas canvas, Offset offset, double width, double height) {
    if (lassoPoints.length < 1) {
      return;
    }
    // var path = Path();
    // path.moveTo(
    //     lassoPoints.first.x + offset.dx, lassoPoints.first.y + offset.dy);
    for (int i = 1; i < lassoPoints.length; i++) {
      var currentPoint = lassoPoints[i];
      var lastPoint = lassoPoints[i - 1];
      canvas.drawLine(
          Offset(currentPoint.x + offset.dx, currentPoint.y + offset.dy),
          Offset(lastPoint.x + offset.dx, lastPoint.y + offset.dy),
          Paint()
            ..color = Colors.red
            ..strokeWidth = 2);
    }
    canvas.drawLine(
        Offset(startPoint.x + offset.dx, startPoint.y + offset.dy),
        Offset(lassoPoints.last.x + offset.dx, lassoPoints.last.y + offset.dy),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2);
    // path.lineTo(
    //     lassoPoints.first.x + offset.dx, lassoPoints.first.y + offset.dy);
    // canvas.drawPath(path, Paint()..color = Colors.red);
  }

  static Widget buildSelection(
    List<PaintElement> paintElements,
    Offset offset,
    VoidCallback refreshFromElement,
  ) {
    // if (paintElements == null || paintElements.length == 0) {
    //   return null;
    // }
    Offset? startMoveOffset;
    double leftest, rightest, topest, bottomest;
    bottomest = paintElements.first.getBottomY();
    topest = paintElements.first.getTopY();
    leftest = paintElements.first.getLeftX();
    rightest = paintElements.first.getRightX();
    for (int i = 0; i < paintElements.length; i++) {
      var element = paintElements[i];
      if (element.getBottomY() > bottomest) {
        bottomest = element.getBottomY();
      }
      if (element.getTopY() < topest) {
        topest = element.getTopY();
      }
      if (element.getLeftX() < leftest) {
        leftest = element.getLeftX();
      }
      if (element.getRightX() > rightest) {
        rightest = element.getRightX();
      }
    }
    print(
        "leftest: $leftest, rightest: $rightest, topest: $topest, bottomest: $bottomest");

    return StatefulBuilder(builder: ((context, setState) {
      return Positioned(
        top: topest + offset.dy,
        left: leftest + offset.dx,
        width: rightest - leftest,
        height: bottomest - topest,
        child: GestureDetector(
            onPanStart: (details) {
              startMoveOffset = details.globalPosition;
            },
            onPanUpdate: (details) {
              if (startMoveOffset == null) {
                return;
              }
              var newOffset = details.globalPosition - startMoveOffset!;
              for (int i = 0; i < paintElements.length; i++) {
                var element = paintElements[i];
                element.moveByOffset(newOffset);
              }
              startMoveOffset = details.globalPosition;
              // refreshFromElement();
              topest += newOffset.dy;
              leftest += newOffset.dx;
              rightest += newOffset.dx;
              bottomest += newOffset.dy;
              setState(() {});
            },
            onPanEnd: (details) {
              startMoveOffset = null;
              refreshFromElement();
            },
            child: Container(
              color: Colors.red.withOpacity(0.2),
            )),
      );
    }));
  }
}
