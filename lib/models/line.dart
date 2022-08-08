import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';

class Line extends PaintElement {
  List<LineFragment> fragments = [];
  Line(Paint paint) : super(paint);
  bool isLineRendered = false;

  @override
  void drawCurrent(Canvas canvas, Offset offset, double width, double height) {
    Path path = Path();
    Path? _currentPath;
    isLineRendered = false;
    for (LineFragment fragment in fragments) {
      _currentPath = fragment.getPath(offset, width, height);
      if (_currentPath != null) {
        path.addPath(_currentPath, Offset.zero);
        isLineRendered = true;
      }
    }
    if (isLineRendered) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  Widget build(BuildContext context, Offset offset, double width, double height,
      bool disableGestureDetection, VoidCallback refreshFromElement) {
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
    // TODO: implement build
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
}

class LinePainter extends CustomPainter {
  Path path;
  Paint _paint;
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
