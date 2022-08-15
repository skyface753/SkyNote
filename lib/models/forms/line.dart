import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/forms/form_base.dart';
import 'package:skynote/models/selections/lasso_selection.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../selections/selection_base.dart';

class LineForm extends PaintElement with BaseForm {
  vm.Vector2 a;
  vm.Vector2 b;

  LineForm(this.a, this.b, Paint paint) : super(paint);

  static const int lineCorrection = 10;
  @override
  void setEndpoint(vm.Vector2 point) {
    if (_isBetween(point.y, a.y - lineCorrection, a.y + lineCorrection)) {
      point.y = a.y;
    } else if (_isBetween(
        point.x, a.x - lineCorrection, a.x + lineCorrection)) {
      point.x = a.x;
    }

    b = point;
  }

  @override
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
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
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

  @override
  bool isItAPoint() {
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

  @override
  bool checkSelection(SelectionBase selection) {
    if (selection.checkCollision(a) && selection.checkCollision(b)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  double getBottomY() {
    if (a.y > b.y) {
      return a.y;
    } else {
      return b.y;
    }
  }

  @override
  double getLeftX() {
    if (a.x < b.x) {
      return a.x;
    } else {
      return b.x;
    }
  }

  @override
  double getRightX() {
    if (a.x > b.x) {
      return a.x;
    } else {
      return b.x;
    }
  }

  @override
  double getTopY() {
    if (a.y < b.y) {
      return a.y;
    } else {
      return b.y;
    }
  }

  @override
  void moveByOffset(Offset offset) {
    a.x += offset.dx;
    a.y += offset.dy;

    b.x += offset.dx;
    b.y += offset.dy;
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
    //TODO Check if line is in bounds (called in build)
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

bool _isBetween(double checkValue, double value1, double value2) {
  if (value1 > value2) {
    return checkValue > value2 && checkValue < value1;
  } else {
    return checkValue > value1 && checkValue < value2;
  }
}
