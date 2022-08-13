import 'package:vector_math/vector_math_64.dart' as vm;

class Intersections {
  static bool intersectAsSegment(
      vm.Vector2 p, vm.Vector2 p2, vm.Vector2 q, vm.Vector2 q2) {
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
}

const double _epsilon = 1e-10;

bool _isZero(double d) {
  return d.abs() < _epsilon;
}
