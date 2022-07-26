import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skynote/helpers/paint_convert_by_dark_mode.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/forms/form_base.dart';
import 'package:skynote/models/selections/lasso_selection.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class CircleForm extends PaintElement with BaseForm {
  vm.Vector2 center;
  double radius;
  CircleForm(this.center, this.radius, Paint paint) : super(paint);
  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool isDarkMode,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    return CustomPaint(
      painter: CircleFormPainter(this, offset, width, height, isDarkMode),
    );
  }

  @override
  void drawCurrent(
    Canvas canvas,
    Offset offset,
    double width,
    double height,
    bool isDarkMode,
  ) {
    //TODO Check if line is in bounds
    paintConvertByDark(isDarkMode, paint, () {
      canvas.drawCircle(
          Offset(center.x + offset.dx, center.y + offset.dy), radius, paint);
    });
  }

  @override
  bool checkSelection(SelectionBase selection) {
    // TODO Better
    if (selection.checkCollision(center)) {
      return true;
    }
    return false;
  }

  @override
  double getBottomY() {
    return center.y + radius;
  }

  @override
  double getLeftX() {
    return center.x - radius;
  }

  @override
  double getRightX() {
    return center.x + radius;
  }

  @override
  double getTopY() {
    return center.y - radius;
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    double distanceAX = center.x - lineEraser.a.x;
    double distanceAY = center.y - lineEraser.a.y;
    double distanceBX = center.x - lineEraser.b.x;
    double distanceBY = center.y - lineEraser.b.y;

    double distanceA = sqrt(pow(distanceAX, 2) + pow(distanceAY, 2));
    double distanceB = sqrt(pow(distanceBX, 2) + pow(distanceBY, 2));

    if (distanceA + distanceB < radius * 2 + paint.strokeWidth &&
        distanceA + distanceB > radius * 2 - paint.strokeWidth) {
      return true;
    }
    return false;
  }

  @override
  void moveByOffset(Offset offset) {
    center = vm.Vector2(center.x + offset.dx, center.y + offset.dy);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.circleForm.index,
      'centerX': center.x,
      'centerY': center.y,
      'radius': radius,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  CircleForm.fromJson(Map<String, dynamic> json)
      : center = vm.Vector2(json['centerX'], json['centerY']),
        radius = json['radius'],
        super(paintConverter.paintFromJson(json['paint']));
  @override
  void setEndpoint(vm.Vector2 point) {
    radius = center.distanceTo(point);
  }

  @override
  bool isItAPoint() {
    return radius == 0;
  }
}

class CircleFormPainter extends CustomPainter {
  CircleForm circleForm;
  Offset offset;
  double width;
  double height;
  bool isDarkMode;
  CircleFormPainter(
      this.circleForm, this.offset, this.width, this.height, this.isDarkMode);
  @override
  void paint(Canvas canvas, Size size) {
    circleForm.drawCurrent(canvas, offset, width, height, isDarkMode);
    // vm.Vector2 center = vm.Vector2(
    //     circleForm.center.x + offset.dx, circleForm.center.y + offset.dy);
    // canvas.drawCircle(
    //     Offset(center.x, center.y), circleForm.radius, circleForm.paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
