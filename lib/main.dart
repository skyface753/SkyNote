import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/point.dart';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:zoom_widget/zoom_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InfiniteCanvasPage(),
    );
  }
}

enum CanvasState { pan, draw, erase, zoom }

String _canvasStateToString(CanvasState state) {
  switch (state) {
    case CanvasState.pan:
      return 'pan';
    case CanvasState.draw:
      return 'draw';
    case CanvasState.erase:
      return 'erase';
    case CanvasState.zoom:
      return 'zoom';
  }
}

class InfiniteCanvasPage extends StatefulWidget {
  const InfiniteCanvasPage({Key? key}) : super(key: key);

  @override
  InfiniteCanvasPageState createState() => InfiniteCanvasPageState();
}

class InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  // List<Offset> points = [];
  CanvasState canvasState = CanvasState.draw;

  List<LineFragment> _currentLineFragments = [];
  final List<PaintElement> _paintElements = [];
  vm.Vector2? lineStart;

  late LineFragment _lineEraser;

  final Map<int, Offset> _pointerMap = {};

  Offset offset = Offset(0, 0);

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

  double currScale = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            canvasState == CanvasState.draw ? Colors.blue : Colors.red,
        onPressed: () {
          setState(() {
            if (canvasState != CanvasState.draw) {
              canvasState = CanvasState.draw;
            } else {
              canvasState = CanvasState.pan;
            }
          });
        },
        child: Text(
          _canvasStateToString(canvasState),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.grey,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.black,
                  onPressed: () {
                    if (_paintElements.isNotEmpty) {
                      _paintElements.removeLast();
                    }
                    setState(() {});
                  },
                ),
                // const Text(
                //   'Sky',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                DropdownButton(
                  value: dropdownValueColor,
                  items: colorItems
                      .map(
                        (color) => DropdownMenuItem(
                          value: color,
                          child: ColoredBox(
                            color: color,
                            child: const SizedBox(
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
                  icon: const Icon(Icons.delete),
                  color: CanvasState.erase == canvasState
                      ? Colors.red
                      : Colors.black,
                  onPressed: () {
                    setState(() {
                      if (canvasState == CanvasState.erase) {
                        canvasState = CanvasState.draw;
                      } else {
                        canvasState = CanvasState.erase;
                      }
                    });
                  },
                ),
                //Save Button
                IconButton(
                  icon: const Icon(Icons.save),
                  color: Colors.black,
                  onPressed: () {
                    var allJson =
                        _paintElements.map((e) => e.toJson()).toList();
                    print(allJson);
                  },
                ),
                // Zoom Button
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  color: Colors.black,
                  onPressed: () {
                    setState(() {
                      if (currScale < 4) {
                        currScale += 0.5;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  color: Colors.black,
                  onPressed: () {
                    setState(() {
                      if (currScale >= 1.5) {
                        currScale -= 0.5;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            // child: Zoom(
            //   maxZoomHeight: 1800,
            //   maxZoomWidth: 1800,
            //   enableScroll: false,
            // child: Zoom(
            //   maxZoomWidth: 1800,
            //   maxZoomHeight: 1800,
            //   initZoom: 0.5,
            //   enableScroll: false,
            // child: OnlyOnePointerRecognizerWidget(
            child: Transform.scale(
              scale: currScale,
              alignment: Alignment.topLeft,
              child: Listener(
                onPointerDown: (event) => {
                  setState(() {
                    if (canvasState == CanvasState.draw ||
                        canvasState == CanvasState.erase) {
                      lineStart = vm.Vector2(event.localPosition.dx - offset.dx,
                          event.localPosition.dy - offset.dy);
                    }
                  })
                },

                onPointerMove: (event) => {
                  setState(() {
                    if (canvasState == CanvasState.pan) {
                      offset += event.delta;
                      print("Should move");
                    } else if (canvasState == CanvasState.draw) {
                      if (lineStart == null) {
                        lineStart = vm.Vector2(
                            event.localPosition.dx - offset.dx,
                            event.localPosition.dy - offset.dy);
                      } else {
                        _currentLineFragments.add(LineFragment(
                          lineStart!,
                          vm.Vector2(event.localPosition.dx - offset.dx,
                              event.localPosition.dy - offset.dy),
                        ));
                        lineStart = vm.Vector2(
                            event.localPosition.dx - offset.dx,
                            event.localPosition.dy - offset.dy);
                      }
                    } else if (canvasState == CanvasState.erase) {
                      _lineEraser = LineFragment(
                        lineStart!,
                        vm.Vector2(event.localPosition.dx - offset.dx,
                            event.localPosition.dy - offset.dy),
                      );
                      lineStart = vm.Vector2(event.localPosition.dx - offset.dx,
                          event.localPosition.dy - offset.dy);
                      for (int i = _paintElements.length - 1; i >= 0; i--) {
                        if (_paintElements[i]
                            .intersectAsSegments(_lineEraser)) {
                          _paintElements.removeAt(i);
                        }
                      }
                    }
                  })
                },
                onPointerUp: (event) => {
                  if (canvasState == CanvasState.draw)
                    {
                      if (lineStart != null)
                        {
                          if (_currentLineFragments.isEmpty)
                            {
                              _paintElements
                                  .add(Point(lineStart!.x, lineStart!.y, paint))
                            }
                          else
                            {
                              _paintElements.add(Line(
                                _currentLineFragments,
                                paint,
                              )),
                              _currentLineFragments = []
                            }
                        }
                    },
                  setState(() {})
                },
                // child: GestureDetector(

                //   onPanDown: (details) {
                //     setState(() {
                //       if (canvasState == CanvasState.draw ||
                //           canvasState == CanvasState.erase) {
                //         lineStart = vm.Vector2(
                //             details.localPosition.dx - offset.dx,
                //             details.localPosition.dy - offset.dy);
                //       }
                //     });
                //   },
                //   onPanUpdate: (details) {
                //     setState(() {
                //       if (canvasState == CanvasState.pan) {
                //         offset += details.delta;
                //       } else if (canvasState == CanvasState.draw) {
                //         if (lineStart == null) {
                //           lineStart = vm.Vector2(
                //               details.localPosition.dx - offset.dx,
                //               details.localPosition.dy - offset.dy);
                //         } else {
                //           _currentLineFragments.add(LineFragment(
                //             lineStart!,
                //             vm.Vector2(details.localPosition.dx - offset.dx,
                //                 details.localPosition.dy - offset.dy),
                //           ));
                //           lineStart = vm.Vector2(
                //               details.localPosition.dx - offset.dx,
                //               details.localPosition.dy - offset.dy);
                //         }
                //       } else if (canvasState == CanvasState.erase) {
                //         _lineEraser = LineFragment(
                //           lineStart!,
                //           vm.Vector2(details.localPosition.dx - offset.dx,
                //               details.localPosition.dy - offset.dy),
                //         );
                //         lineStart = vm.Vector2(
                //             details.localPosition.dx - offset.dx,
                //             details.localPosition.dy - offset.dy);
                //         for (int i = _paintElements.length - 1; i >= 0; i--) {
                //           if (_paintElements[i]
                //               .intersectAsSegments(_lineEraser)) {
                //             _paintElements.removeAt(i);
                //           }
                //         }
                //       }
                //     });
                //   },
                //   onPanEnd: (details) {
                //     if (canvasState == CanvasState.draw) {
                //       if (lineStart != null) {
                //         if (_currentLineFragments.isEmpty) {
                //           _paintElements
                //               .add(Point(lineStart!.x, lineStart!.y, paint));
                //         } else {
                //           _paintElements.add(Line(
                //             _currentLineFragments,
                //             paint,
                //           ));
                //           _currentLineFragments = [];
                //         }
                //       }
                //     }
                //     setState(() {});
                //   },
                child: SizedBox.expand(
                  child: ClipRRect(
                    child: CustomPaint(
                        painter: CanvasCustomPainter(_paintElements,
                            _currentLineFragments, offset, paint)),
                  ),
                ),
              ),
              // ),
            ),
          )
        ],
      ),
    );
  }
}

class CanvasCustomPainter extends CustomPainter {
  final List<LineFragment> _currentLineFragments;

  final List<PaintElement> _paintElements;
  Offset offset;
  final Paint _drawingPaint;

  CanvasCustomPainter(this._paintElements, this._currentLineFragments,
      this.offset, this._drawingPaint);

  @override
  void paint(Canvas canvas, Size size) {
    //define canvas background color
    Paint background = Paint()..color = Colors.white;

    //define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    for (final paintElement in _paintElements) {
      paintElement.draw(canvas, offset);
    }

    for (var fragment in _currentLineFragments) {
      fragment.draw(canvas, offset, _drawingPaint);
    }
  }

  @override
  bool shouldRepaint(CanvasCustomPainter oldDelegate) {
    return true;
  }
}

class OnlyOnePointerRecognizer extends OneSequenceGestureRecognizer {
  int _p = 0;

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);

    if (_p == 0) {
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  String get debugDescription => 'only one pointer recognizer';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }
  }
}

class OnlyOnePointerRecognizerWidget extends StatelessWidget {
  final Widget? child;

  OnlyOnePointerRecognizerWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(gestures: <Type, GestureRecognizerFactory>{
      OnlyOnePointerRecognizer:
          GestureRecognizerFactoryWithHandlers<OnlyOnePointerRecognizer>(
              () => OnlyOnePointerRecognizer(),
              (OnlyOnePointerRecognizer instance) {})
    }, child: child);
  }
}
