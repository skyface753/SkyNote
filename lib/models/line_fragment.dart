// import 'dart:math';
import 'dart:math';
import 'dart:ui';

import 'package:skynote/models/line_eraser.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import 'lasso_selection.dart';

class LineFragment {
  final vm.Vector2 a;
  final vm.Vector2 b;
  bool isRenderd = false;

  LineFragment(this.a, this.b);

  Path? getPath(Offset offset, double width, double height) {
    // Check if a and b ar in the display
    if ((-offset.dx <= a.x &&
            a.x <= -offset.dx + width &&
            -offset.dy <= a.y &&
            a.y <= -offset.dy + height) ||
        (-offset.dx <= b.x &&
            b.x <= -offset.dx + width &&
            -offset.dy <= b.y &&
            b.y <= -offset.dy + height)) {
      final path = Path();
      path.moveTo(offset.dx + a.x, offset.dy + a.y);
      path.lineTo(offset.dx + b.x, offset.dy + b.y);
      isRenderd = true;
      return path;
    } else {
      isRenderd = false;
      // print("LineFragment: a and b are not in the display");
      return null;
    }
  }

  bool checkLassoSelection(LassoSelection lassoSelection) {
    if (!isRenderd) {
      return false;
    }
    if (lassoSelection.checkCollision(a) && lassoSelection.checkCollision(b)) {
      return true;
    } else {
      return false;
    }
  }

  void moveByOffset(Offset offset) {
    a.x += offset.dx;
    a.y += offset.dy;
    b.x += offset.dx;
    b.y += offset.dy;
  }

  bool intersectAsSegments(LineEraser other, bool byDistance) {
    if (!isRenderd) {
      print("Not in display => not intersect");
      return false;
    }
    // Small lines intersects by distance, large lines by collision
    if (byDistance) {
      final distance = sqrt(pow(other.b.x - a.x, 2) + pow(other.b.y - a.y, 2));
      print("Distance: $distance");
      if (distance < 5) {
        return true;
      } else {
        return false;
      }
    }
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
