import 'dart:ui';

import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_new.dart';

class LineForm extends PaintElement {
  LNPoint startPoint;
  LNPoint endPoint;

  LineForm(this.startPoint, this.endPoint, Paint paint) : super(paint);

  void setEndpoint(double x, double y) {
    endPoint = LNPoint(x, y);
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
    canvas.drawLine(Offset(startPoint.x + offset.dx, startPoint.y + offset.dy),
        Offset(endPoint.x + offset.dx, endPoint.y + offset.dy), paint);
  }

  @override
  bool intersectAsSegments(EraserLine lineEraser) {
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
      'a': startPoint.toJson(),
      'b': endPoint.toJson(),
      'paint': paintConverter.paintToJson(paint),
    };
  }

  LineForm.fromJson(Map<String, dynamic> json)
      : startPoint = LNPoint.fromJson(json['a']),
        endPoint = LNPoint.fromJson(json['b']),
        super(paintConverter.paintFromJson(json['paint']));
}
