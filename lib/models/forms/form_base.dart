import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

//TODO INTERSECT on DELETE for all elements
abstract class BaseForm {
  void drawCurrent(
    Canvas canvas,
    Offset offset,
    double width,
    double height,
    bool isDarkMode,
  ); // TODO Merge with build or draw
  void setEndpoint(vm.Vector2 point);
  bool isItAPoint();
}
