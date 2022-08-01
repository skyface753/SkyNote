import 'dart:ui';

import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';

class Line extends PaintElement {
  List<LineFragment> fragments = [];
  Line(Paint paint) : super(paint);

  @override
  void draw(Canvas canvas, Offset offset, double width, double height) {
    // List<Path> paths = [];
    Path path = Path();
    Path? _currentPath;
    for (LineFragment fragment in fragments) {
      _currentPath = fragment.getPath(offset, width, height);
      if (_currentPath != null) {
        path.addPath(_currentPath, Offset.zero);
      }
      // path.addPath(, Offset.zero);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool intersectAsSegments(lineEraser) {
    for (LineFragment fragment in fragments) {
      if (fragment.intersectAsSegments(lineEraser)) {
        return true;
      }
    }
    return false;
  }

  void addFragment(LineFragment fragment) {
    fragments.add(fragment);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.line.index,
      'fragments': fragments.map((e) => e.toJson()).toList(),
      'paint': paintConverter.paintToJson(paint),
    };
  }

  Line.fromJson(Map<String, dynamic> json)
      : fragments = List<LineFragment>.from(
            json['fragments'].map((e) => LineFragment.fromJson(e))),
        super(paintConverter.paintFromJson(json['paint']));
}
