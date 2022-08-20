import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';
import 'package:skynote/helpers/paint_convert_by_dark_mode.dart';
import 'package:skynote/models/forms/arrow.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ArrowDoubleForm extends ArrowForm {
  ArrowDoubleForm(vm.Vector2 a1, vm.Vector2 b2, Paint paint)
      : super(a1, b2, paint);

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool isDarkMode,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    return CustomPaint(
      painter: ArrowDoublePainter(this, offset, width, height, isDarkMode),
    );
  }

  @override
  void drawCurrent(
    Canvas canvas,
    Offset offset,
    double width,
    double height,
    bool isDarkMode,
  ) {
    //TODO Check if line is in bounds
    paintConvertByDark(isDarkMode, paint, () {
      paint.strokeJoin = StrokeJoin.round;
      Path path = Path();
      path.moveTo(a1.x + offset.dx, a1.y + offset.dy);
      path.lineTo(b2.x + offset.dx, b2.y + offset.dy);
      path = ArrowPath.make(path: path, isDoubleSided: true);
      canvas.drawPath(path, paint);
    });
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.arrowDoubleForm.index,
      'a1': {'x': a1.x, 'y': a1.y},
      'b2': {'x': b2.x, 'y': b2.y},
      'paint': paintConverter.paintToJson(paint)
    };
  }

  ArrowDoubleForm.fromJson(Map<String, dynamic> json)
      : super(
            vm.Vector2(json['a1']['x'], json['a1']['y']),
            vm.Vector2(json['b2']['x'], json['b2']['y']),
            paintConverter.paintFromJson(json['paint']));
}

class ArrowDoublePainter extends CustomPainter {
  ArrowDoubleForm form;
  Offset offset;
  double width;
  double height;
  bool isDarkMode;
  ArrowDoublePainter(
      this.form, this.offset, this.width, this.height, this.isDarkMode);
  @override
  void paint(Canvas canvas, Size size) {
    form.drawCurrent(canvas, offset, width, height, isDarkMode);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
