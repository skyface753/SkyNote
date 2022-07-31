import 'dart:ui';

import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/line_old.dart';
import 'package:skynote/models/point.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class LineForm extends PaintElement {
  vm.Vector2 a;
  vm.Vector2 b;

  LineForm(this.a, this.b, Paint paint) : super(paint);

  void setEndpoint(double x, double y) {
    b = vm.Vector2(x, y);
  }

  @override
  void draw(Canvas canvas, Offset offset, double width, double height) {
    // if (startPoint.x + offset.dx < offset.dx ||
    //     startPoint.x + offset.dx > offset.dx + width ||
    //     startPoint.y + offset.dy < offset.dy ||
    //     startPoint.y + offset.dy > offset.dy + height) {
    //   return;
    // }
    // if (endPoint.x + offset.dx < offset.dx ||
    //     endPoint.x + offset.dx > offset.dx + width ||
    //     endPoint.y + offset.dy < offset.dy ||
    //     endPoint.y + offset.dy > offset.dy + height) {
    //   return;
    // }
    canvas.drawLine(Offset(a.x + offset.dx, a.y + offset.dy),
        Offset(b.x + offset.dx, b.y + offset.dy), paint);
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    // if (lineEraser.b == null) {
    return false;
    // }
    // int testWidth = 5;
    // int xAddPlus = (a.x + testWidth).toInt();
    // int xAddMinus = (a.x - testWidth).toInt();
    // int yAddPlus = (a.y + testWidth).toInt();
    // int yAddMinus = (a.y - testWidth).toInt();
    // if (xAddPlus < lineEraser.a.x ||
    //     xAddMinus > lineEraser.b!.x ||
    //     yAddPlus < lineEraser.a.y ||
    //     yAddMinus > lineEraser.b!.y) {
    //   return false;
    // }
    // return true;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'LineForm',
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
}
