import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/lasso_selection.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';

class Line extends PaintElement {
  List<LineFragment> fragments = [];
  Line(Paint paint) : super(paint);
  bool isLineRendered = false;

  void drawCurrent(Canvas canvas, Offset offset, double width, double height) {
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
      canvas.drawPath(path, paint);
    }
  }

  @override
  Widget build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool disableGestureDetection,
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
      painter: LinePainter(path, paint),
    );
  }

  @override
  bool checkLassoSelection(LassoSelection lassoSelection) {
    if (!isLineRendered) {
      return false;
    }
    bool allIn = true;
    for (LineFragment fragment in fragments) {
      if (!fragment.checkLassoSelection(lassoSelection)) {
        allIn = false;
      }
    }
    return allIn;
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
  LinePainter(this.path, this._paint);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
