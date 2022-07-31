import 'package:vector_math/vector_math_64.dart' as vm;

class LineEraser {
  vm.Vector2 a;
  vm.Vector2 b;

  LineEraser(this.a, this.b);

  void nextPoint(double x, double y) {
    a = b;
    b = vm.Vector2(x, y);
  }
}
