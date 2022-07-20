import 'dart:ui';

import 'package:flutter/material.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const MyApp());
}

class Point extends PaintElement {
  double x;
  double y;
  // final Paint _paint;
  Point(this.x, this.y, Paint paint) : super(paint);
  @override
  void draw(Canvas canvas) {
    canvas.drawPoints(PointMode.points, [Offset(x, y)], paint);
  }

  @override
  void checkCollision(LineFragment lineEraser) {
    double pointP1 = lineEraser.start.x;
    double pointP2 = lineEraser.start.y;
    double pointQ1 = lineEraser.end.x;
    double pointQ2 = lineEraser.end.y;
    double pointD1 = x;
    double pointD2 = y;

    double lambdaR1 = (pointD1 - pointP1) / (-pointP1 + pointQ1);
    double lambdaR2 = (pointD2 - pointP2) / (-pointP2 + pointQ2);

    if (lambdaR1 != lambdaR2) {
      print("Keine Kollision");
      return;
    }
    if (lambdaR1 >= 0 && lambdaR1 <= 1) {
      print("Kollision");
    }
  }
}

class LineFragment {
  Point start;
  Point end;
  LineFragment(this.start, this.end);
  void draw(Canvas canvas, Paint paint) {
    canvas.drawLine(
      Offset(start.x, start.y),
      Offset(end.x, end.y),
      paint,
    );
  }

  // Prüfe ob Punkt innerhalb des Fragments
  // void checkCollision(Point pointd) {
  //   double pointP1 = start.x;
  //   double pointP2 = start.y;
  //   double pointQ1 = end.x;
  //   double pointQ2 = end.y;
  //   double pointD1 = pointd.x;
  //   double pointD2 = pointd.y;

  //   double lambdaR1 = (pointD1 - pointP1) / (-pointP1 + pointQ1);
  //   double lambdaR2 = (pointD2 - pointP2) / (-pointP2 + pointQ2);

  //   if (lambdaR1 != lambdaR2) {
  //     print("Keine Kollision");
  //     return;
  //   }
  //   if ((lambdaR1 >= 0 && lambdaR1 <= 1) && (lambdaR2 >= 0 && lambdaR2 <= 1)) {
  //     print("Kollision");
  //   }
  // }
}

class Line extends PaintElement {
  List<LineFragment> _fragments;
  // Paint _paint;
  Line(this._fragments, Paint paint) : super(paint);
  @override
  void draw(Canvas canvas) {
    for (LineFragment fragment in _fragments) {
      // _paint.color = Colors.yellow;
      fragment.draw(canvas, paint);
    }
  }

  @override
  void checkCollision(LineFragment lineEraser) {}
}

abstract class PaintElement {
  Paint paint;
  PaintElement(Paint currpaint)
      : paint = Paint()
          ..color = currpaint.color
          ..strokeWidth = currpaint.strokeWidth
          ..style = currpaint.style
          ..strokeCap = currpaint.strokeCap;

  void draw(Canvas canvas);
  void checkCollision(LineFragment lineEraser);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // List<Line> _lines = [];
  List<LineFragment> _currentLineFragments = [];
  final List<PaintElement> _paintElements = [];
  Point? lineStart;

  bool _eraserMode = false;
  late LineFragment _lineEraser;

  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0
    ..color = Colors.indigo;

  // For COLOR PICKER
  // Initial Selected Value
  Color dropdownValueColor = Colors.indigo;

  // List of items in our dropdown menu
  var colorItems = [
    Colors.indigo,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.black,
    Colors.white,
  ];
  // FOR Stroke WIDTH PICKER
  // Initial Selected Value
  double dropdownValueStrokeWidth = 4.0;
  // List of items in our dropdown menu
  var strokeWidthItems = [
    1.0,
    2.0,
    3.0,
    4.0,
    5.0,
    6.0,
    7.0,
    8.0,
    9.0,
    10.0,
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(

          // Outer white container with padding
          body: Column(
        children: <Widget>[
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.black,
                  onPressed: () {
                    if (_paintElements.isNotEmpty) {
                      _paintElements.removeLast();
                    }
                    setState(() {});
                  },
                ),
                Text(
                  'Skysocial',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton(
                  value: dropdownValueColor,
                  items: colorItems
                      .map(
                        (color) => DropdownMenuItem(
                          value: color,
                          child: ColoredBox(
                            color: color,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (Color? newValue) {
                    setState(() {
                      dropdownValueColor = newValue!;
                      paint.color = newValue;
                    });
                  },
                ),
                DropdownButton(
                  value: dropdownValueStrokeWidth,
                  items: strokeWidthItems
                      .map(
                        (strokeWidth) => DropdownMenuItem(
                          value: strokeWidth,
                          child: Text(
                            '$strokeWidth',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (double? newValue) {
                    setState(() {
                      dropdownValueStrokeWidth = newValue!;
                      paint.strokeWidth = newValue;
                    });
                  },
                  dropdownColor: Colors.white,
                ),
                // Eraser Button
                IconButton(
                  icon: Icon(Icons.delete),
                  color: _eraserMode ? Colors.red : Colors.black,
                  onPressed: () {
                    setState(() {
                      _eraserMode = !_eraserMode;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
                // pass double.infinity to prevent shrinking of the painter area to 0.
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Listener(
                  onPointerDown: (PointerDownEvent event) {
                    lineStart = Point(
                        event.localPosition.dx, event.localPosition.dy, paint);
                    setState(() {});
                  },
                  onPointerMove: (PointerMoveEvent event) {
                    if (_eraserMode) {
                      _lineEraser = LineFragment(
                        lineStart!,
                        Point(event.localPosition.dx, event.localPosition.dy,
                            paint),
                      );
                      lineStart = Point(event.localPosition.dx,
                          event.localPosition.dy, paint);
                      for (PaintElement element in _paintElements) {
                        element.checkCollision(_lineEraser);
                      }
                      return;
                    }
                    if (lineStart == null) {
                      lineStart = Point(event.localPosition.dx,
                          event.localPosition.dy, paint);
                    } else {
                      _currentLineFragments.add(LineFragment(
                          lineStart!,
                          Point(event.localPosition.dx, event.localPosition.dy,
                              paint)));
                      // lineStart = null;
                      lineStart = Point(event.localPosition.dx,
                          event.localPosition.dy, paint);
                    }
                    setState(() {});
                    // setState(() {});
                  },
                  onPointerUp: (PointerUpEvent event) {
                    if (_currentLineFragments.isEmpty) {
                      _paintElements.add(Point(event.localPosition.dx,
                          event.localPosition.dy, paint));
                    } else {
                      _paintElements.add(Line(_currentLineFragments, paint));
                      _currentLineFragments = [];
                    }
                    setState(() {});
                  },
                  // child: Expanded(
                  child: CustomPaint(
                      painter: FaceOutlinePainter(
                          _paintElements, _currentLineFragments, paint)),
                )),
          ),
          // )
        ],
      )),
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  // final List<Point> _points;
  // final List<Line> _lines;
  final List<LineFragment> _currentLineFragments;

  final List<PaintElement> _paintElements;
  final Paint _paint;

  FaceOutlinePainter(
      this._paintElements, this._currentLineFragments, this._paint);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the paint objects
    for (final paintElement in _paintElements) {
      paintElement.draw(canvas);
    }

    for (var fragment in _currentLineFragments) {
      fragment.draw(canvas, _paint);
    }
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => true;
}
