import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class LineForm extends PaintElement {
  vm.Vector2 a;
  vm.Vector2 b;

  LineForm(this.a, this.b, Paint paint) : super(paint);

  void setEndpoint(double x, double y) {
    b = vm.Vector2(x, y);
  }

  void drawCurrent(Canvas canvas, Offset offset, double width, double height) {
    // Todo Check if line is in bounds
    canvas.drawLine(Offset(a.x + offset.dx, a.y + offset.dy),
        Offset(b.x + offset.dx, b.y + offset.dy), paint);
  }

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool disableGestureDetection,
      VoidCallback refreshFromElement) {
    //TODO Check if line is in bounds
    return CustomPaint(
      painter: LineFormPainter(this, offset, width, height),
    );
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    LineForm line1 = this;
    final p = line1.a;
    final p2 = line1.b;

    final q = lineEraser.a;
    final q2 = lineEraser.b;

    var r = p2 - p;
    var s = q2 - q;
    var rxs = r.cross(s);
    var qpxr = (q - p).cross(r);

    if (_isZero(rxs) && _isZero(qpxr)) {
      return false;
    }

    if (_isZero(rxs) && !_isZero(qpxr)) return false;

    var t = (q - p).cross(s) / rxs;

    var u = (q - p).cross(r) / rxs;

    if (!_isZero(rxs) && (0 <= t && t <= 1) && (0 <= u && u <= 1)) {
      return true;
    }

    return false;
  }

  bool isLineAPoint() {
    return a.x == b.x && a.y == b.y;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.lineForm.index,
      'aX': a.x,
      'aY': a.y,
      'bX': b.x,
      'bY': b.y,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  LineForm.fromJson(Map<String, dynamic> json)
      : a = vm.Vector2(json['aX'], json['aY']),
        b = vm.Vector2(json['bX'], json['bY']),
        super(paintConverter.paintFromJson(json['paint']));

  bool equals(LineForm? lineForm) {
    if (lineForm == null) {
      return false;
    }
    if (a.x == lineForm.a.x &&
        a.y == lineForm.a.y &&
        b.x == lineForm.b.x &&
        b.y == lineForm.b.y) {
      return true;
    } else {
      return false;
    }
  }
}

const double _epsilon = 1e-10;

bool _isZero(double d) {
  return d.abs() < _epsilon;
}

class LineFormPainter extends CustomPainter {
  LineForm lineForm;
  Offset offset;
  double width;
  double height;
  LineFormPainter(this.lineForm, this.offset, this.width, this.height);
  @override
  void paint(Canvas canvas, Size size) {
    //TODO Check if line is in bounds
    canvas.drawLine(
        Offset(lineForm.a.x + offset.dx, lineForm.a.y + offset.dy),
        Offset(lineForm.b.x + offset.dx, lineForm.b.y + offset.dy),
        lineForm.paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
