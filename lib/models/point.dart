import 'dart:ui';

import 'package:skynote/helpers/paint_convert.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_fragment.dart';

var paintConverter = PaintConverter();

class Point extends PaintElement {
  double x;
  double y;
  // final Paint _paint;
  Point(this.x, this.y, Paint paint) : super(paint);
  @override
  void draw(Canvas canvas, Offset offset) {
    canvas.drawPoints(
        PointMode.points, [Offset(x + offset.dx, y + offset.dy)], paint);
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
  bool intersectAsSegments(LineFragment lineEraser) {
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
