import 'dart:ui';

import 'package:skynote/helpers/paint_convert.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_fragment.dart';

var paintConverter = PaintConverter();

class Line extends PaintElement {
  List<LineFragment> _fragments;
  // Paint _paint;
  Line(this._fragments, Paint paint) : super(paint);
  @override
  void draw(Canvas canvas, Offset offset) {
    for (LineFragment fragment in _fragments) {
      fragment.draw(canvas, offset, paint);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fragments': _fragments.map((fragment) => fragment.toJson()).toList(),
      'paint': paintConverter.paintToJson(paint),
    };
  }

  Line.fromJson(Map<String, dynamic> json)
      : _fragments = List<LineFragment>.from(json['fragments']
            .map((fragment) => LineFragment.fromJson(fragment))),
        super(paintConverter.paintFromJson(json['paint']));

  @override
  bool intersectAsSegments(LineFragment lineEraser) {
    for (LineFragment fragment in _fragments) {
      if (fragment.intersectAsSegments(lineEraser)) {
        return true;
      }
    }
    return false;
  }
}
