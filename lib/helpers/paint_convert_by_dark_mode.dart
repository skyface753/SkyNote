import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void paintConvertByDark(bool isDarkMode, Paint paint, VoidCallback drawThis) {
  if (paint.color == Colors.black && isDarkMode) {
    paint.color = Colors.white;
    drawThis();
    paint.color = Colors.black;
    return;
  } else if (paint.color == Colors.white && !isDarkMode) {
    paint.color = Colors.black;
    drawThis();
    paint.color = Colors.white;
    return;
  }
  drawThis();
}
