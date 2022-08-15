import 'package:flutter/material.dart';

class Pencil {
  PaintingStyle style;
  Color color;
  double strokeWidth;
  StrokeCap strokeCap;

  Pencil(this.style, this.color, this.strokeWidth, this.strokeCap);

  // Empty constructor
  Pencil.empty()
      : style = PaintingStyle.stroke,
        color = Colors.black,
        strokeWidth = 2.0,
        strokeCap = StrokeCap.round;

  Paint getPaint() {
    return Paint()
      ..style = style
      ..strokeCap = strokeCap
      ..strokeWidth = strokeWidth
      ..color = color;
  }

  Pencil.fromJson(Map<String, dynamic> json)
      : style = PaintingStyle.values[json['style']],
        color = Color(json['color']),
        strokeWidth = json['strokeWidth'],
        strokeCap = StrokeCap.values[json['strokeCap']];

  Map<String, dynamic> toJson() {
    return {
      'style': style.index,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'strokeCap': strokeCap.index,
    };
  }

  static List<Pencil> getDefaultPencils() {
    return [
      Pencil(PaintingStyle.stroke, Colors.black, 4.0, StrokeCap.round),
      Pencil(PaintingStyle.stroke, Colors.blue, 4.0, StrokeCap.round),
      Pencil(PaintingStyle.stroke, Colors.red, 4.0, StrokeCap.round),
    ];
  }
}
