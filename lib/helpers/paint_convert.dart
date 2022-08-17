import 'dart:ui';

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
}
