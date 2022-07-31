import 'dart:ui';

import 'package:skynote/helpers/paint_convert.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/line_old.dart';

var paintConverter = PaintConverter();

class Point extends PaintElement {
  double x;
  double y;
  // final Paint _paint;
  Point(this.x, this.y, Paint paint) : super(paint) {
    print("X: $x, Y: $y");
  }
  @override
  void draw(Canvas canvas, Offset offset, double width, double height) {
    // print("Offset: $offset, Width: $width, Height: $height");
    if (-offset.dx <= x &&
        x <= -offset.dx + width &&
        -offset.dy <= y &&
        y <= -offset.dy + height) {
      canvas.drawPoints(
          PointMode.points, [Offset(x + offset.dx, y + offset.dy)], paint);
    } else {
      print("Point is out of canvas");
    }
    // print("Point out of bounds");
    // if (this.x + offset.dx < offset.dx ||
    //     this.x + offset.dx > offset.dx + width ||
    //     this.y + offset.dy < offset.dy ||
    //     this.y + offset.dy > offset.dy + height) {
    //   return;
    // }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Point',
      'x': x,
      'y': y,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  Point.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'],
        super(paintConverter.paintFromJson(json['paint']));

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    int testWidth = 5;
    int xAddPlus = (x + testWidth).toInt();
    int xAddMinus = (x - testWidth).toInt();
    int yAddPlus = (y + testWidth).toInt();
    int yAddMinus = (y - testWidth).toInt();

    if (lineEraser.a.x < xAddPlus &&
        lineEraser.a.x > xAddMinus &&
        lineEraser.a.y < yAddPlus &&
        lineEraser.a.y > yAddMinus) {
      print("Point intersects in A segment");
      return true;
    }
    if (lineEraser.b.x < xAddPlus &&
        lineEraser.b.x > xAddMinus &&
        lineEraser.b.y < yAddPlus &&
        lineEraser.b.y > yAddMinus) {
      print("Point intersects in B segment");
      return true;
    }
    return false;
  }
}
