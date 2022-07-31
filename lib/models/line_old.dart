// import 'dart:ui';
// import 'package:skynote/helpers/paint_convert.dart';
// import 'package:skynote/models/base_paint_element.dart';
// import 'package:vector_math/vector_math_64.dart' as vm;
// import 'dart:math';
// // import 'package:skynote/models/line_fragment.dart';

// var paintConverter = PaintConverter();

// class LineNew extends PaintElement {
//   List<LNPoint> _points = [];

//   LineNew(double x, double y, Paint paint) : super(paint) {
//     _points.add(LNPoint(x, y));
//   }

//   void addPoint(double x, double y) {
//     _points.add(LNPoint(x, y));
//   }

//   @override
//   void draw(Canvas canvas, Offset offset, double width, double height) {
//     if (_points.length < 2) {
//       return;
//     }

//     var path = Path();
//     path.moveTo(offset.dx + _points[0].x, offset.dy + _points[0].y);
//     for (int i = 1; i < _points.length; i++) {
//       path.lineTo(offset.dx + _points[i].x, offset.dy + _points[i].y);
//     }
//     canvas.drawPath(path, paint);
//   }

//   bool equals(LineNew other) {
//     if (other._points.length == _points.length) return true;
//     return false;
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'type': 'LineNew',
//       'points': _points.map((point) => point.toJson()).toList(),
//       'paint': paintConverter.paintToJson(paint),
//     };
//   }

//   LineNew.fromJson(Map<String, dynamic> json)
//       : _points = List<LNPoint>.from(
//             json['points'].map((point) => LNPoint.fromJson(point))),
//         super(paintConverter.paintFromJson(json['paint']));

//   @override
//   bool intersectAsSegments(EraserLine lineEraser) {
//     if (lineEraser.b == null || _points.length < 2) {
//       return false;
//     }
//     final q = vm.Vector2(lineEraser.a.x, lineEraser.a.y);
//     final q2 = vm.Vector2(lineEraser.b!.x, lineEraser.b!.y);

//     for (int i = 0; i < _points.length - 1; i++) {
//       final p = vm.Vector2(_points[i].x, _points[i].y);
//       final p2 = vm.Vector2(_points[i + 1].x, _points[i + 1].y);

//       var r = p2 - p;
//       var s = q2 - q;
//       var rxs = r.cross(s);
//       var qpxr = (q - p).cross(r);

//       if (_isZero(rxs) && _isZero(qpxr)) {
//         // collinear
//         return false;
//       }

//       if (_isZero(rxs) && !_isZero(qpxr)) {
//         // parallel and non-intersecting
//         return false;
//       }
//       var t = (q - p).cross(s) / rxs;

//       var u = (q - p).cross(r) / rxs;

//       if (!_isZero(rxs) && (0 <= t && t <= 1) && (0 <= u && u <= 1)) {
//         // intersection
//         print("Intersect");
//         return true;
//       }
//       print("No Intersect");
//     }
//     return false;
//   }

//   int get pointCount => _points.length;
// }

// const double _epsilon = 1e-10;
// bool _isZero(double d) {
//   return d.abs() < _epsilon;
// }

// class LNPoint {
//   double x;
//   double y;

//   LNPoint(this.x, this.y);

//   Map<String, dynamic> toJson() {
//     return {
//       'x': x,
//       'y': y,
//     };
//   }

//   static LNPoint fromJson(Map<String, dynamic> json) {
//     return LNPoint(json['x'].toDouble(), json['y'].toDouble());
//   }
// }

// class EraserLine {
//   LNPoint a;
//   LNPoint? b;

//   EraserLine(this.a);

//   nextPoint(double x, double y) {
//     if (b == null) {
//       b = LNPoint(x, y);
//     } else {
//       a = b!;
//       b = LNPoint(x, y);
//     }
//     // b = LNPoint(x, y);
//   }
// }
