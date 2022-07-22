import 'dart:ui';

import 'package:skynote/models/line_fragment.dart';

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
}
