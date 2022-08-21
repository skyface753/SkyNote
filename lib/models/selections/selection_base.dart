import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

abstract class SelectionBase {
  vm.Vector2 startPoint;

  SelectionBase(this.startPoint);

  void setPoint(vm.Vector2 point);
  bool checkCollision(vm.Vector2 otherPoint);
  void drawCurrent(Canvas canvas, Offset offset, double width, double height,
      bool isDarkMode);

  static Widget buildSelection(List<PaintElement> paintElements, Offset offset,
      VoidCallback refreshFromElement, double currScale) {
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
              var newOffset =
                  (details.globalPosition - startMoveOffset!) / currScale;
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
