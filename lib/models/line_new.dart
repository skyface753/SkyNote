import 'dart:ui';
import 'package:skynote/helpers/paint_convert.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_fragment.dart';

var paintConverter = PaintConverter();

class LineNew extends PaintElement {
  List<Point> _points = [];

  LineNew(Point startPoint, Paint paint) : super(paint) {
    _points.add(startPoint);
  }

  @override
  void draw(Canvas canvas, Offset offset) {
    if (_points.length < 2) {
      return;
    }
    var path = Path();
    path.moveTo(offset.dx + _points[0].x, offset.dy + _points[0].y);
    for (int i = 1; i < _points.length; i++) {
      path.lineTo(offset.dx + _points[i].x, offset.dy + _points[i].y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'LineNew',
      'points': _points.map((point) => point.toJson()).toList(),
      'paint': paintConverter.paintToJson(paint),
    };
  }

  LineNew.fromJson(Map<String, dynamic> json)
      : _points = List<Point>.from(
            json['points'].map((point) => Point.fromJson(point))),
        super(paintConverter.paintFromJson(json['paint']));

  @override
  bool intersectAsSegments(LineFragment lineEraser) {
    // for (int i = 0; i < _points.length - 1; i++) {
    //   if (lineEraser.intersectAsSegments(LineFragment(_points[i], _points[i + 1]))) {
    //     return true;
    //   }
    // }
    return false;
  }
}

class Point {
  double x;
  double y;

  Point(this.x, this.y);

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  static Point fromJson(Map<String, dynamic> json) {
    return Point(json['x'], json['y']);
  }
}
