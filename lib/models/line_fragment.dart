// import 'dart:math';
import 'dart:ui';

import 'package:skynote/models/line_eraser.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class LineFragment {
  final vm.Vector2 a;
  final vm.Vector2 b;

  const LineFragment(this.a, this.b);

  Path getPath(Offset offset) {
    final path = Path();
    path.moveTo(offset.dx + a.x, offset.dy + a.y);
    path.lineTo(offset.dx + b.x, offset.dy + b.y);
    return path;
  }

  // vm.Vector2 project(vm.Vector2 p) {
  //   final lineDir = (b - a).normalized();
  //   var v = p - a;
  //   var d = v.dot(lineDir);
  //   return a + (lineDir * d);
  // }

  // double distanceToPoint(vm.Vector2 p) {
  //   final d = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);

  //   return d.sign * sqrt(d.abs());
  // }

  // double? slope() {
  //   final x1 = a.x;
  //   final y1 = a.y;
  //   final x2 = b.x;
  //   final y2 = b.y;

  //   if (x1 == x2) return null;
  //   return (y1 - y2) / (x1 - x2);
  // }

  bool intersectAsSegments(LineEraser other) {
    LineFragment line1 = this;
    final p = line1.a;
    final p2 = line1.b;

    final q = other.a;
    final q2 = other.b;

    var r = p2 - p;
    var s = q2 - q;
    var rxs = r.cross(s);
    var qpxr = (q - p).cross(r);

    if (_isZero(rxs) && _isZero(qpxr)) {
      return false;
    }

    if (_isZero(rxs) && !_isZero(qpxr)) return false;

    var t = (q - p).cross(s) / rxs;

    var u = (q - p).cross(r) / rxs;

    if (!_isZero(rxs) && (0 <= t && t <= 1) && (0 <= u && u <= 1)) {
      return true;
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'aX': a.x,
      'aY': a.y,
      'bX': b.x,
      'bY': b.y,
    };
  }

  LineFragment.fromJson(Map<String, dynamic> json)
      : a = vm.Vector2(json['aX'], json['aY']),
        b = vm.Vector2(json['bX'], json['bY']);
}

const double _epsilon = 1e-10;

bool _isZero(double d) {
  return d.abs() < _epsilon;
}
