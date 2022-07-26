import 'package:flutter/material.dart';
import 'package:skynote/helpers/paint_convert_by_dark_mode.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/selections/lasso_selection.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class Line extends PaintElement {
  List<LineFragment> fragments = [];
  Line(Paint paint) : super(paint);
  bool isLineRendered = false;

  void drawCurrent(
    Canvas canvas,
    Offset offset,
    double width,
    double height,
    bool isDarkMode,
  ) {
    Path path = Path();
    Path? currentPath;
    isLineRendered = false;
    for (LineFragment fragment in fragments) {
      currentPath = fragment.getPath(offset, width, height);
      if (currentPath != null) {
        path.addPath(currentPath, Offset.zero);
        isLineRendered = true;
      }
    }
    if (isLineRendered) {
      paintConvertByDark(isDarkMode, paint, () {
        canvas.drawPath(path, paint);
      });
    }
  }

  @override
  Widget build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool isDarkMode,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    Path path = Path();
    Path? currentPath;
    isLineRendered = false;
    for (LineFragment fragment in fragments) {
      currentPath = fragment.getPath(offset, width, height);
      if (currentPath != null) {
        path.addPath(currentPath, Offset.zero);
        isLineRendered = true;
      }
    }
    if (isLineRendered) {
      path.close();
    }
    return CustomPaint(
      painter: LinePainter(path, paint, isDarkMode),
    );
  }

  @override
  bool checkSelection(SelectionBase selection) {
    if (!isLineRendered) {
      print("Line not rendered");
      return false;
    }
    print("Check in Line");
    // bool allIn = true;
    // vm.Vector2 a1 = vm.Vector2(getLeftX(), getTopY()); // top left
    // vm.Vector2 a2 = vm.Vector2(getRightX(), getTopY()); // top right
    // vm.Vector2 b1 = vm.Vector2(getLeftX(), getBottomY()); // bottom left
    // vm.Vector2 b2 = vm.Vector2(getRightX(), getBottomY()); // bottom right
    // if (selection.checkCollision(a1) &&
    //     selection.checkCollision(a2) &&
    //     selection.checkCollision(b1) &&
    //     selection.checkCollision(b2)) {
    //   return true;
    // }
    // return false;
    for (LineFragment fragment in fragments) {
      if (fragment.checkSelection(selection)) {
        // allIn = false;
        return true;
      }
    }
    return false;
  }

  @override
  bool intersectAsSegments(lineEraser) {
    if (!isLineRendered) {
      print('Line is not rendered');
      return false;
    }
    bool byDistance = fragments.length < 3;
    print("byDistance: $byDistance");
    for (LineFragment fragment in fragments) {
      if (fragment.intersectAsSegments(lineEraser, byDistance)) {
        return true;
      }
    }
    return false;
  }

  void addFragment(LineFragment fragment) {
    fragments.add(fragment);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.line.index,
      'fragments': fragments.map((e) => e.toJson()).toList(),
      'paint': paintConverter.paintToJson(paint),
    };
  }

  Line.fromJson(Map<String, dynamic> json)
      : fragments = List<LineFragment>.from(
            json['fragments'].map((e) => LineFragment.fromJson(e))),
        super(paintConverter.paintFromJson(json['paint']));

  @override
  double getBottomY() {
    if (fragments.isEmpty) {
      return 0.0;
    }
    double bottomY = fragments.first.a.y;
    for (LineFragment fragment in fragments) {
      if (fragment.a.y > bottomY) {
        bottomY = fragment.a.y;
      }
      if (fragment.b.y > bottomY) {
        bottomY = fragment.b.y;
      }
    }
    return bottomY;
  }

  @override
  double getLeftX() {
    if (fragments.isEmpty) {
      return 0.0;
    }
    double leftX = fragments.first.a.x;
    for (LineFragment fragment in fragments) {
      if (fragment.a.x < leftX) {
        leftX = fragment.a.x;
      }
      if (fragment.b.x < leftX) {
        leftX = fragment.b.x;
      }
    }
    return leftX;
  }

  @override
  double getRightX() {
    if (fragments.isEmpty) {
      return 0.0;
    }
    double rightX = fragments.first.a.x;
    for (LineFragment fragment in fragments) {
      if (fragment.a.x > rightX) {
        rightX = fragment.a.x;
      }
      if (fragment.b.x > rightX) {
        rightX = fragment.b.x;
      }
    }
    return rightX;
  }

  @override
  double getTopY() {
    if (fragments.isEmpty) {
      return 0.0;
    }
    double topY = fragments.first.a.y;
    for (LineFragment fragment in fragments) {
      if (fragment.a.y < topY) {
        topY = fragment.a.y;
      }
      if (fragment.b.y < topY) {
        topY = fragment.b.y;
      }
    }
    return topY;
  }

  @override
  void moveByOffset(Offset offset) {
    for (LineFragment fragment in fragments) {
      fragment.moveByOffset(offset);
    }
  }
}

class LinePainter extends CustomPainter {
  Path path;
  final Paint _paint;
  final bool isDarkMode;
  LinePainter(this.path, this._paint, this.isDarkMode);
  @override
  void paint(Canvas canvas, Size size) {
    paintConvertByDark(isDarkMode, _paint, () {
      canvas.drawPath(path, _paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
