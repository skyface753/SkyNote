import 'dart:ui';

import 'package:skynote/models/line.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/point.dart';

abstract class PaintElement {
  Paint paint;
  PaintElement(Paint currpaint)
      : paint = Paint()
          ..color = currpaint.color
          ..strokeWidth = currpaint.strokeWidth
          ..style = currpaint.style
          ..strokeCap = currpaint.strokeCap;

  void draw(Canvas canvas, Offset offset);
  bool intersectAsSegments(LineFragment lineEraser);

  Map<String, dynamic> toJson();

  // From Json
  static List<PaintElement> fromJson(List<dynamic> json) {
    return json.map((e) {
      if (e['type'] == 'Point') {
        return Point.fromJson(e);
      } else if (e['type'] == 'Line') {
        return Line.fromJson(e);
      } else {
        throw Exception('Unknown type');
      }
    }).toList();
  }
}
