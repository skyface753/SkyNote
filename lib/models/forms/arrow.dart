import 'package:flutter/material.dart';
import 'package:skynote/helpers/intersections.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/forms/form_base.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/selections/lasso_selection.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:arrow_path/arrow_path.dart';

class ArrowForm extends PaintElement with BaseForm {
  vm.Vector2 a1; // Start
  vm.Vector2 b2; // End

  ArrowForm(this.a1, this.b2, Paint paint) : super(paint);

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool disableGestureDetection,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    return CustomPaint(
      painter: ArrowPainter(this, offset, width, height),
    );
  }

  @override
  void drawCurrent(Canvas canvas, Offset offset, double width, double height) {
    //TODO Check if line is in bounds

    paint.strokeJoin = StrokeJoin.round;
    Path path = Path();
    path.moveTo(a1.x + offset.dx, a1.y + offset.dy);
    path.lineTo(b2.x + offset.dx, b2.y + offset.dy);
    path = ArrowPath.make(path: path);
    canvas.drawPath(path, paint);
  }

  @override
  bool checkSelection(SelectionBase selection) {
    // TODO Better
    if (selection.checkCollision(a1) && selection.checkCollision(b2)) {
      return true;
    }
    return false;
  }

  @override
  double getBottomY() {
    if (b2.y > a1.y) {
      return b2.y;
    } else {
      return a1.y;
    }
  }

  @override
  double getLeftX() {
    if (a1.x < b2.x) {
      return a1.x;
    } else {
      return b2.x;
    }
  }

  @override
  double getRightX() {
    if (a1.x > b2.x) {
      return a1.x;
    } else {
      return b2.x;
    }
  }

  @override
  double getTopY() {
    if (a1.y < b2.y) {
      return a1.y;
    } else {
      return b2.y;
    }
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    return Intersections.intersectAsSegment(lineEraser.a, lineEraser.b, a1, b2);
  }

  @override
  void moveByOffset(Offset offset) {
    a1 = vm.Vector2(a1.x + offset.dx, a1.y + offset.dy);
    b2 = vm.Vector2(b2.x + offset.dx, b2.y + offset.dy);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.arrowForm.index,
      'a1X': a1.x,
      'a1Y': a1.y,
      'b2X': b2.x,
      'b2Y': b2.y,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  ArrowForm.fromJson(Map<String, dynamic> json)
      : a1 = vm.Vector2(json['a1X'], json['a1Y']),
        b2 = vm.Vector2(json['b2X'], json['b2Y']),
        super(paintConverter.paintFromJson(json['paint']));

  @override
  void setEndpoint(vm.Vector2 point) {
    b2 = point;
  }

  @override
  bool isItAPoint() {
    return a1.x == b2.x && a1.y == b2.y;
  }
}

class ArrowPainter extends CustomPainter {
  ArrowForm arrow;
  Offset offset;
  double width;
  double height;
  ArrowPainter(this.arrow, this.offset, this.width, this.height);
  @override
  void paint(Canvas canvas, Size size) {
    arrow.paint.strokeJoin = StrokeJoin.round;
    Path path = Path();
    path.moveTo(arrow.a1.x + offset.dx, arrow.a1.y + offset.dy);
    path.lineTo(arrow.b2.x + offset.dx, arrow.b2.y + offset.dy);
    path = ArrowPath.make(path: path);
    canvas.drawPath(path, arrow.paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
