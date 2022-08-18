import 'dart:ui';

import 'package:flutter/material.dart';

class PaintConverter {
  Map<String, dynamic> paintToJson(Paint paint) {
    return {
      'color': paint.color.value,
      'strokeWidth': paint.strokeWidth,
      'style': paint.style.index,
      'strokeCap': paint.strokeCap.index,
    };
  }

  Paint paintFromJson(Map<String, dynamic> json) {
    return Paint()
      ..color = Color(json['color'])
      ..strokeWidth = json['strokeWidth'].toDouble()
      ..style = PaintingStyle.values[json['style']]
      ..strokeCap = StrokeCap.values[json['strokeCap']];
  }

  List<Map<String, dynamic>> paintsListToJson(List<Paint> paints) {
    return paints.map((paint) => paintToJson(paint)).toList();
  }

  List<Paint> paintsListFromJson(List<dynamic> json) {
    return json.map((paint) => paintFromJson(paint)).toList();
  }

  // Paint paintColorByBackground(Paint paint, bool isDarkBackground){
  //   Paint newPaint = Paint()..color = paint.color
  //   ..strokeWidth = paint.strokeWidth
  //   ..style = paint.style
  //   ..strokeCap = paint.strokeCap;
  //   if(isDarkBackground && paint.color == Colors.black){
  //     newPaint.color = Colors.white;
  //   }else if(!isDarkBackground && paint.color == Colors.white){
  //     newPaint.color = Colors.black;
  //   }
  //   return newPaint;
  // }
}
