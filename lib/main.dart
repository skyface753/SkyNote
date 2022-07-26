import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:skynote/components/drawer.dart';
import 'package:skynote/google_drive_search.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line.dart';
import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/note_book.dart';
import 'package:skynote/models/point.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
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
        home: const InfiniteCanvasPage());
  }
}

enum CanvasState { pan, draw, erase, zoom }

class PointerMap {
  vm.Vector2 start;
  vm.Vector2? current;
  vm.Vector2? end;
  PointerMap(this.start, this.current, this.end);
}

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
  List<PaintElement>? _paintElements;
  vm.Vector2? lineStart;

  late LineFragment _lineEraser;
  Map<int, PointerMap> _pointerMap = {};

  Offset offset = const Offset(0, 0);

  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0
    ..color = Colors.indigo;

  // For COLOR PICKER
  // Initial Selected Value
  Color dropdownValueColor = Colors.indigo;

  final LocalStorage storage = LocalStorage('some_key.json');

  @override
  void initState() {
    // createTest();
    getSavedData();
    super.initState();
  }

  NoteBook _noteBook = NoteBook("TestBook");

  void createTest() async {
    NoteSection section = NoteSection("TestSection");
    Note note = Note("TestNote");

    section.addNote(note);
    _noteBook.addSection(section);
    await storage.ready;
    _paintElements = note.elements;
    setState(() {});
  }

  void saveData() async {
    await storage.ready;
    storage.setItem('noteBook', _noteBook.toJson());
    print(_noteBook.toJson());
  }

  void getSavedData() async {
    await storage.ready;
    var noteBookJson = storage.getItem('noteBook');
    if (noteBookJson != null) {
      _noteBook = NoteBook.fromJson(noteBookJson);
      int selectedSectionIndex = _noteBook.selectedSectionIndex ?? 0;
      int selectedNoteIndex = _noteBook.selectedNoteIndex ?? 0;
      try {
        _paintElements = _noteBook
            .sections[selectedSectionIndex].notes[selectedNoteIndex].elements;
      } catch (e) {
        _paintElements = null;
      }
      setState(() {});
    } else {
      print("No data found");
    }
  }

  // Future<void> getDataFromStorage() async {
  //   await storage.ready;
  //   try {
  //     Map<String, dynamic> notebookData = storage.getItem('Notebook');
  //     if (notebookData != null && notebookData.isNotEmpty) {
  //       _noteBook = NoteBook.fromJson(notebookData);
  //     }
  //   } catch (e) {
  //     storage.deleteItem('Notebook');
  //     print("No data in storage");
  //   }
  // }

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
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool useMobileLayout = false;

  String newNotebookName = "";
  String newSectionName = "";
  String newNoteName = "";

  Widget mobileDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Notebook: ${_noteBook.name}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Edit Notebook"),
                              content: TextField(
                                onChanged: (value) {
                                  newNotebookName = value;
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      "Notebook Name (" + _noteBook.name + ")",
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text("Save"),
                                  onPressed: () {
                                    setState(() {
                                      _noteBook.name = newNotebookName;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Section: ${_noteBook.selectedSectionIndex}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Note: ${_noteBook.selectedNoteIndex}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            // Text('Skynote'),
          ),
          _noteBook.selectedSectionIndex == null
              ? Container()
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _noteBook.selectedSectionIndex = null;
                    });
                  },
                  //TODO: Check that section is selected before continuing to draw
                  child: const Text("Back to Section")),
          _noteBook.selectedSectionIndex == null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: _noteBook.sections.length,
                  itemBuilder: (drawercontext, index) {
                    return ListTile(
                      title: Text(_noteBook.sections[index].name),
                      onTap: () {
                        setState(() {
                          _noteBook.selectedSectionIndex = index;
                        });
                      },
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _noteBook.sections.removeAt(index);
                            });
                          },
                        ),
                        //Rename
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            newSectionName = _noteBook.sections[index].name;
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text(
                                          "Rename Section (${_noteBook.sections[index].name})"),
                                      content: TextField(
                                        onChanged: (value) {
                                          newSectionName = value;
                                        },
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("Rename"),
                                          onPressed: () {
                                            setState(() {
                                              _noteBook.sections[index].name =
                                                  newSectionName;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ));
                          },
                        ),
                      ]),
                    );
                  },
                )
              :
              //Notes
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _noteBook
                      .sections[_noteBook.selectedSectionIndex!].notes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_noteBook
                          .sections[_noteBook.selectedSectionIndex!]
                          .notes[index]
                          .name),
                      onTap: () {
                        setState(() {
                          _noteBook.selectedNoteIndex = index;
                          _paintElements = _noteBook
                              .sections[_noteBook.selectedSectionIndex!]
                              .notes[_noteBook.selectedNoteIndex!]
                              .elements;
                          // Close the drawer
                          Navigator.pop(context);
                        });
                      },
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _noteBook
                                  .sections[_noteBook.selectedSectionIndex!]
                                  .notes
                                  .removeAt(index);
                            });
                          },
                        ),
                        //Rename
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            newSectionName = _noteBook
                                .sections[_noteBook.selectedSectionIndex!]
                                .notes[index]
                                .name;
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text(
                                          "Rename Note (${_noteBook.sections[_noteBook.selectedSectionIndex!].notes[index].name})"),
                                      content: TextField(
                                        onChanged: (value) {
                                          newNoteName = value;
                                        },
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("Rename"),
                                          onPressed: () {
                                            setState(() {
                                              _noteBook
                                                  .sections[_noteBook
                                                      .selectedSectionIndex!]
                                                  .notes[index]
                                                  .name = newNoteName;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ));
                          },
                        ),
                      ]),
                    );
                  },
                ),
          _noteBook.selectedSectionIndex == null
              ? ElevatedButton(
                  child: const Text("Add Section"),
                  onPressed: () {
                    setState(() {
                      _noteBook.addSection(NoteSection("New Section" +
                          _noteBook.sections.length.toString()));
                    });
                  },
                )
              : ElevatedButton(
                  child: const Text("Add Note"),
                  onPressed: () {
                    setState(() {
                      _noteBook.sections[_noteBook.selectedSectionIndex!]
                          .addNote(Note("New Note" +
                              _noteBook
                                  .sections[_noteBook.selectedSectionIndex!]
                                  .notes
                                  .length
                                  .toString()));
                    });
                  },
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = shortestSide < 600;
    if (useMobileLayout) {
      print("Mobile Layout");
    }

    return Scaffold(
      drawer: useMobileLayout ? mobileDrawer() : null,
      // drawer: Drawer(
      //   child: ListView(
      //     // Important: Remove any padding from the ListView.
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.blue,
      //         ),
      //         child: Text('Drawer Header'),
      //       ),
      //       ListTile(
      //         title: const Text('Item 1'),
      //         onTap: () {
      //           // Update the state of the app.
      //           // ...
      //         },
      //       ),
      //       // ListTile(
      //       //   title: const Text('Load'),
      //       //   onTap: () {
      //       //     var data = storage.getItem('Test');
      //       //     print(data);
      //       //     List<PaintElement> paintElements = PaintElement.fromJson(data);
      //       //     setState(() {
      //       //       _paintElements.clear();
      //       //       _paintElements.addAll(paintElements);
      //       //     });
      //       //   },
      //       // ),
      //     ],
      //   ),
      // ),
      key: scaffoldKey,
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
          style: const TextStyle(color: Colors.white),
        ),
      ),
      appBar: _paintElements == null
          ? AppBar(
              title: const Text('Skynote'),
            )
          : null,
      body: _paintElements == null
          ? Center(
              child: ElevatedButton(
              child: const Text('Create Empty Notebook'),
              onPressed: () {
                setState(() {
                  _noteBook = NoteBook("Test");
                });
                scaffoldKey.currentState!.openDrawer();
              },
            ))
          : Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  height: 70,
                  width: double.infinity,
                  color: Colors.grey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () =>
                              scaffoldKey.currentState?.openDrawer(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.black,
                          onPressed: () {
                            if (_paintElements!.isNotEmpty) {
                              _paintElements!.removeLast();
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
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.black),
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
                            saveData();
                            // var allJson =
                            //     _paintElements!.map((e) => e.toJson()).toList();
                            // // print(allJson);
                            // storage.setItem('Test', allJson);
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
                        // Googlew Login
                        IconButton(
                          icon: const Icon(Icons.account_circle),
                          color: Colors.black,
                          onPressed: () async {
                            await Firebase.initializeApp(
                              options: DefaultFirebaseOptions.currentPlatform,
                            );
                            final _googleSignIn = signIn.GoogleSignIn(
                                clientId:
                                    "244156996836-79kchr7r10f2qnqln9b81v58dnmg38li.apps.googleusercontent.com",
                                scopes: [drive.DriveApi.driveScope]);

                            //         _googleSignIn.sc
                            // _googleSignIn
                            //   ..standard(scopes: );
                            final signIn.GoogleSignInAccount? account =
                                await _googleSignIn.signIn();
                            print("User account $account");
                          },
                        ),
                      ],
                    ),
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
                      onPointerDown: (event) {
                        _pointerMap[event.pointer] = PointerMap(
                            vm.Vector2(
                                event.localPosition.dx, event.localPosition.dy),
                            null,
                            null);
                        if (_pointerMap.length > 1) {
                          CanvasState.zoom;
                        } else if (canvasState == CanvasState.draw ||
                            canvasState == CanvasState.erase) {
                          lineStart = vm.Vector2(
                              event.localPosition.dx - offset.dx,
                              event.localPosition.dy - offset.dy);
                        }
                        setState(() {});
                      },

                      onPointerMove: (event) {
                        print(event.kind);
                        try {
                          _pointerMap[event.pointer]?.current = vm.Vector2(
                              event.localPosition.dx, event.localPosition.dy);
                        } catch (e) {
                          print(e);
                        }
                        if (canvasState == CanvasState.zoom) {}
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
                            lineStart = vm.Vector2(
                                event.localPosition.dx - offset.dx,
                                event.localPosition.dy - offset.dy);
                            for (int i = _paintElements!.length - 1;
                                i >= 0;
                                i--) {
                              if (_paintElements![i]
                                  .intersectAsSegments(_lineEraser)) {
                                _paintElements!.removeAt(i);
                              }
                            }
                          }
                        });
                      },
                      onPointerUp: (event) => {
                        _pointerMap.remove(event.pointer),
                        if (canvasState == CanvasState.draw)
                          {
                            if (lineStart != null)
                              {
                                if (_currentLineFragments.isEmpty)
                                  {
                                    _paintElements!.add(Point(
                                        lineStart!.x, lineStart!.y, paint))
                                  }
                                else
                                  {
                                    _paintElements!.add(Line(
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
                              painter: CanvasCustomPainter(_paintElements!,
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

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers!..addAll(_headers));
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = new http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
