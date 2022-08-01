import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flash/flash.dart';
import 'package:image_picker/image_picker.dart';

import 'package:crypto/crypto.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/line_form.dart';
import 'package:skynote/models/line_fragment.dart';
// import 'package:skynote/models/line.dart';
// import 'package:skynote/models/line_fragment.dart';
import 'package:skynote/models/note_book.dart';
import 'package:skynote/models/paint_image.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/screens/login_screen.dart';
import 'package:skynote/screens/notebook_selection_screen.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:appwrite/appwrite.dart';

String storageID = '62e2afd619bea62ecafd';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppWriteCustom.initAppwrite();
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (context) => NotebookSelectionScreen(),
          '/login': (context) => LoginScreen(),
          // '/notebook': (context) => InfiniteCanvasPage(),
        },
        debugShowCheckedModeBanner: false,
        initialRoute: '/');
  }
}

enum CanvasState { pan, draw, erase, zoom, form }

enum Forms { none, line, rectangle, circle, triangle }

// enum Background { white, lines, checkered, black }

class PointerMap {
  vm.Vector2 lastPosition;
  PointerMap(this.lastPosition);
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
    case CanvasState.form:
      return 'form';
  }
}

String _formsToString(Forms form) {
  switch (form) {
    case Forms.none:
      return 'Forms';
    case Forms.line:
      return 'line';
    case Forms.rectangle:
      return 'rectangle';
    case Forms.circle:
      return 'circle';
    case Forms.triangle:
      return 'triangle';
  }
}

class InfiniteCanvasPage extends StatefulWidget {
  final String? noteBookId;
  const InfiniteCanvasPage({Key? key, required this.noteBookId})
      : super(key: key);

  @override
  InfiniteCanvasPageState createState() => InfiniteCanvasPageState();
}

class InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  // List<Offset> points = [];
  CanvasState canvasState = CanvasState.draw;
  // Background background = Background.lines;

  // List<LineFragment> _currentLineFragments = [];
  Line? _currentLine;
  List<PaintElement>? _paintElements;
  vm.Vector2? lineStart;

  // late LineFragment _lineEraser;
  LineEraser? _lineEraser;
  Map<int, PointerMap> _pointerMap = {};

  late String oldNotebookName;

  //Forms
  LineForm? _lineForm;

  Offset offset = const Offset(0, 0);

  Storage appwriteStorage = AppWriteCustom().getAppwriteStorage();

  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0
    ..color = Colors.indigo;

  // For COLOR PICKER
  // Initial Selected Value
  Color dropdownValueColor = Colors.indigo;

  @override
  void initState() {
    getNotebook();
    // loading = false;
    super.initState();
  }

  Future<void> getNotebook() async {
    // Init new Notebook and Upload to AppWrite
    if (widget.noteBookId == null) {
      _noteBook = NoteBook("Neues Notizbuch", Background.white);
      final file = await getLocalFile('neues_notizbuch.json');
      file.writeAsStringSync(_noteBook.toString());
      final inputFile = InputFile(path: file.path, filename: _noteBook.name);

      _noteBook.appwriteFileId = await appwriteStorage
          .createFile(bucketId: storageID, fileId: 'unique()', file: inputFile)
          .then((value) => value.$id);
      loading = false;
      oldNotebookName = _noteBook.name;
      setState(() {});
      return;
    }
    String notebookId = widget.noteBookId!;

    Uint8List file = await appwriteStorage.getFileDownload(
        bucketId: '62e2afd619bea62ecafd', fileId: notebookId);
    print("File downloaded");
    String fileContent = String.fromCharCodes(file);
    print(fileContent);

    _noteBook =
        NoteBook.fromJson(json.decode(fileContent), (() => setState(() {})));
    _noteBook.appwriteFileId = notebookId;
    oldNotebookName = _noteBook.name;

    if (_noteBook.selectedSectionIndex != null &&
        _noteBook.selectedNoteIndex != null) {
      try {
        _paintElements = _noteBook.sections[_noteBook.selectedSectionIndex!]
            .notes[_noteBook.selectedNoteIndex!].elements;
      } catch (e) {}
    }

    loading = false;
    setState(() {});
  }

  void verifyNotebook() async {
    String? notebookId = _noteBook.appwriteFileId;
    if (notebookId == null) {
      showFlashTopBar("Notebook has no ID", false);
      return;
    }

    //AppWrite Notebook Hash
    Uint8List file;
    try {
      file = await appwriteStorage.getFileDownload(
          bucketId: '62e2afd619bea62ecafd', fileId: notebookId);
      print("File downloaded (HASH now)");
    } catch (e) {
      showFlashTopBar("Error getting Notebook Hash Online", false);
      return;
    }
    String fileContent = String.fromCharCodes(file);
    var appwriteFileHash = sha512.convert(utf8.encode(fileContent)).toString();

    //Local Notebook Hash
    String localFileHash = _noteBook.getHash();
    if (appwriteFileHash != localFileHash) {
      showFlashTopBar(
          "Notizbuch wurde geändert (Hash has changed - online)", false);
      return;
    } else {
      //Test FromJson
      try {
        NoteBook testNoteBook =
            NoteBook.fromJson(json.decode(fileContent), () {});
        String testNotebookHash = testNoteBook.getHash();
        if (testNotebookHash == localFileHash) {
          showFlashTopBar("Notizbuch ist aktuell (Hash ist gleich)", true);
        } else {
          showFlashTopBar("Notizbuch Hash Error (Local)", false);
        }
      } catch (e) {
        showFlashTopBar("Fehler beim Laden des Notizbuchs", false);
        return;
      }
    }
  }

  void showFlashTopBar(String text, bool success) {
    showFlash(
        context: context,
        duration: const Duration(seconds: 1, milliseconds: 500),
        builder: (_, controller) {
          return Flash(
              controller: controller,
              position: FlashPosition.top,
              behavior: FlashBehavior.floating,
              child: FlashBar(
                content: Text(text,
                    style:
                        TextStyle(color: success ? Colors.green : Colors.red)),
              ));
        });
  }

  late NoteBook _noteBook;

  Future<bool> saveToAppwrite() async {
    try {
      final file = await getLocalFile(_noteBook.appwriteFileId ?? 'blub.json');
      file.writeAsStringSync(_noteBook.toString());
      final inputFile = InputFile(path: file.path, filename: _noteBook.name);
      String fileId = _noteBook.appwriteFileId ?? 'unique()';
      if (_noteBook.appwriteFileId != null &&
          oldNotebookName != _noteBook.name) {
        await appwriteStorage.deleteFile(bucketId: storageID, fileId: fileId);
      }
      var createdFile = await appwriteStorage.createFile(
          bucketId: storageID, fileId: fileId, file: inputFile);
      _noteBook.appwriteFileId = createdFile.$id;
      oldNotebookName = _noteBook.name;
      print("File saved");
      showFlashTopBar("Notizbuch gespeichert", true);
      return true;
    } catch (e) {
      showFlashTopBar("Fehler beim Speichern des Notizbuchs", false);
      return false;
    }
  }

  // List of items in our dropdown menu
  List<Color> colorItems = [
    Colors.indigo,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.black,
    Colors.white,
  ];

  List<Background> backgroundItems = [
    Background.white,
    Background.lines,
    Background.checkered,
    Background.black,
  ];
  Background selectedBackground = Background.white;

  List<Forms> formItems = [
    Forms.none,
    Forms.line,
    Forms.rectangle,
    Forms.circle,
    Forms.triangle,
  ];
  Forms selectedForm = Forms.none;
  // FOR Stroke WIDTH PICKER
  // Initial Selected Value
  double dropdownValueStrokeWidth = 4.0;
  // List of items in our dropdown menu
  List<double> strokeWidthItems = [
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
  double? lastDistance;
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
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _noteBook.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Edit Notebook"),
                              content: TextField(
                                onChanged: (value) {
                                  newNotebookName = value;
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      "Notebook Name (${_noteBook.name})",
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text("Save"),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Note: ${_noteBook.selectedNoteIndex}',
                  style: const TextStyle(
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
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _noteBook.sections.removeAt(index);
                            });
                          },
                        ),
                        //Rename
                        IconButton(
                          icon: const Icon(Icons.edit),
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
                                        ElevatedButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          child: const Text("Rename"),
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
                          icon: const Icon(Icons.delete),
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
                          icon: const Icon(Icons.edit),
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
                                        ElevatedButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          child: const Text("Rename"),
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
                      _noteBook.addSection(NoteSection(
                          "New Section${_noteBook.sections.length}"));
                    });
                  },
                )
              : ElevatedButton(
                  child: const Text("Add Note"),
                  onPressed: () {
                    setState(() {
                      _noteBook.sections[_noteBook.selectedSectionIndex!]
                          .addNote(Note(
                              "New Note${_noteBook.sections[_noteBook.selectedSectionIndex!].notes.length}"));
                    });
                  },
                ),
        ],
      ),
    );
  }

  bool loading = true;
  bool stylusAvailable = false;

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = shortestSide < 600;
    if (useMobileLayout) {
      // print("Mobile Layout");
    }

    return Scaffold(
      //TODO: Tablet Drawer
      drawer: loading == true
          ? null
          : (useMobileLayout ? mobileDrawer() : mobileDrawer()),
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
      body: loading == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _paintElements == null
              ? Center(
                  child: ElevatedButton(
                    child: const Text("Create Section"),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                )
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
                                dropdownValueColor = newValue!;
                                paint.color = newValue;
                                setState(() {});
                              },
                            ), // Background
                            DropdownButton(
                                items: backgroundItems.map((background) {
                                  return DropdownMenuItem(
                                      value: background,
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CustomPaint(
                                            painter:
                                                BackgroundPreview(background)),
                                      ));
                                }).toList(),
                                value: selectedBackground,
                                onChanged: (Background? newValue) {
                                  selectedBackground = newValue!;
                                  _noteBook.defaultBackground = newValue;
                                  setState(() {});
                                }), // Background

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
                                dropdownValueStrokeWidth = newValue!;
                                paint.strokeWidth = newValue;
                                setState(() {});
                              },
                              dropdownColor: Colors.white,
                            ),
                            DropdownButton(
                                items: formItems.map((form) {
                                  return DropdownMenuItem(
                                      value: form,
                                      child: Text(
                                        _formsToString(form),
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ));
                                }).toList(),
                                value: selectedForm,
                                onChanged: (Forms? newValue) {
                                  if (newValue == Forms.none) {
                                    canvasState = CanvasState.draw;
                                  } else {
                                    canvasState = CanvasState.form;
                                  }
                                  selectedForm = newValue!;
                                  setState(() {});
                                }),
                            // Eraser Button
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: CanvasState.erase == canvasState
                                  ? Colors.red
                                  : Colors.black,
                              onPressed: () {
                                if (canvasState == CanvasState.erase) {
                                  canvasState = CanvasState.draw;
                                } else {
                                  canvasState = CanvasState.erase;
                                }
                                setState(() {});
                              },
                            ), //Add an Image
                            IconButton(
                                onPressed: () async {
                                  print("Add Image");
                                  final ImagePicker picker = ImagePicker();
                                  print("ImagePicker");
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  print("Adding Image");
                                  if (image != null) {
                                    print("Image Selected");
                                    InputFile inputFile =
                                        InputFile(path: image.path);
                                    var uploadedFile =
                                        await appwriteStorage.createFile(
                                            bucketId: '62e40e4e2d262cc2e179',
                                            fileId: 'unique()',
                                            file: inputFile);
                                    print("File Uploaded");
                                    PaintImage newPaintImage = PaintImage(
                                        uploadedFile.$id,
                                        vm.Vector2(-offset.dx, -offset.dy),
                                        paint, () {
                                      setState(() {});
                                    });
                                    _paintElements!.add(newPaintImage);
                                    saveToAppwrite();
                                    setState(() {});
                                  } else {
                                    print("Image is null");
                                  }
                                },
                                icon: const Icon(Icons.add_photo_alternate)),
                            //Save Button
                            IconButton(
                              icon: const Icon(Icons.save),
                              color: Colors.black,
                              onPressed: () {
                                //TODO Manual Save
                                print(_noteBook.toString());
                                saveToAppwrite();
                              },
                            ),
                            //Verify Button
                            IconButton(
                              icon: const Icon(Icons.verified_user),
                              color: Colors.black,
                              onPressed: () {
                                verifyNotebook();
                              },
                            ),
                            // Zoom Button
                            IconButton(
                              icon: const Icon(Icons.zoom_in),
                              color: Colors.black,
                              onPressed: () {
                                if (currScale < 4) {
                                  currScale += 0.5;
                                }
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.zoom_out),
                              color: Colors.black,
                              onPressed: () {
                                if (currScale >= 1.5) {
                                  currScale -= 0.5;
                                }
                                setState(() {});
                              },
                            ),
                            // Back to Notebook List Screen
                            IconButton(
                              icon: const Icon(Icons
                                  .logout), // Not sure if this is the right icon
                              color: Colors.black,
                              onPressed: () async {
                                //TODO Show loading dialog while saving
                                if (await saveToAppwrite()) {
                                  Navigator.pushReplacementNamed(context, "/");
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Transform.scale(
                      scale: currScale,
                      alignment: Alignment.topLeft,
                      child: Listener(
                        onPointerDown: (event) {
                          _pointerMap[event.pointer] = PointerMap(
                            vm.Vector2(
                                event.localPosition.dx, event.localPosition.dy),
                          );
                          if (event.kind == PointerDeviceKind.stylus) {
                            stylusAvailable = true;
                            if (canvasState == CanvasState.pan) {
                              canvasState = CanvasState.draw;
                            }
                          }
                          if (event.kind == PointerDeviceKind.touch &&
                              stylusAvailable) {
                            canvasState = CanvasState.pan;
                          }
                          if (_pointerMap.length > 1) {
                            print("More than one pointer");
                            canvasState = CanvasState.zoom;
                          } else if (canvasState == CanvasState.draw) {
                            lineStart = vm.Vector2(
                                event.localPosition.dx - offset.dx,
                                event.localPosition.dy - offset.dy);

                            // _currentLineFragment = LineFragment(
                            //     event.localPosition.dx - offset.dx,
                            //     event.localPosition.dy - offset.dy,
                            //     paint);
                          } else if (canvasState == CanvasState.erase) {
                            //TODO Performance
                            _lineEraser = LineEraser(
                              vm.Vector2(event.localPosition.dx - offset.dx,
                                  event.localPosition.dy - offset.dy),
                              vm.Vector2(event.localPosition.dx - offset.dx,
                                  event.localPosition.dy - offset.dy),
                            );
                            // _lineEraser = EraserLine(LNPoint(
                            //     event.localPosition.dx - offset.dx,
                            //     event.localPosition.dy - offset.dy));
                          } else if (canvasState == CanvasState.form) {
                            if (Forms.line == selectedForm) {
                              _lineForm = LineForm(
                                  vm.Vector2(event.localPosition.dx - offset.dx,
                                      event.localPosition.dy - offset.dy),
                                  vm.Vector2(event.localPosition.dx - offset.dx,
                                      event.localPosition.dy - offset.dy),
                                  paint);
                              // _lineForm = LineForm(
                              //     LNPoint(event.localPosition.dx - offset.dx,
                              //         event.localPosition.dy - offset.dy),
                              //     LNPoint(event.localPosition.dx - offset.dx,
                              //         event.localPosition.dy - offset.dy),
                              //     paint);
                            }
                          }
                          setState(() {});
                        },
                        onPointerMove: (event) {
                          if (canvasState == CanvasState.zoom) {
                            double currPosX = event.localPosition.dx;
                            double currPosY = event.localPosition.dy;
                            double lastPosX =
                                _pointerMap[event.pointer]!.lastPosition.x;
                            double lastPosY =
                                _pointerMap[event.pointer]!.lastPosition.y;
                            // Distace between the two points
                            // d = sqrt((x2 - x1)^2 + (y2 - y1)^2)
                            double distance = sqrt(pow(currPosX - lastPosX, 2) +
                                pow(currPosY - lastPosY, 2));
                            print("Distance: $distance");
                            currScale += distance / 100;
                            setState(() {});
                            try {
                              _pointerMap[event.pointer]!.lastPosition =
                                  vm.Vector2(event.localPosition.dx,
                                      event.localPosition.dy);
                            } catch (e) {
                              print(e);
                            }
                            return;
                          }
                          if (canvasState == CanvasState.pan) {
                            setState(() {
                              offset += event.delta;
                              if (offset.dx > 0) {
                                offset = Offset(0, offset.dy);
                              }
                              if (offset.dy > 0) {
                                offset = Offset(offset.dx, 0);
                              }
                            });
                          } else if (canvasState == CanvasState.draw) {
                            if (lineStart == null) {
                              lineStart = vm.Vector2(
                                  event.localPosition.dx - offset.dx,
                                  event.localPosition.dy - offset.dy);
                              // _currentLine = LineNew(
                              //     event.localPosition.dx - offset.dx,
                              //     event.localPosition.dy - offset.dy,
                              //     paint);
                            } else {
                              setState(() {
                                _currentLine ??= Line(paint);
                                _currentLine!.addFragment(LineFragment(
                                    lineStart!,
                                    vm.Vector2(
                                        event.localPosition.dx - offset.dx,
                                        event.localPosition.dy - offset.dy)));
                                lineStart = vm.Vector2(
                                    event.localPosition.dx - offset.dx,
                                    event.localPosition.dy - offset.dy);
                              });
                            }
                          } else if (canvasState == CanvasState.erase) {
                            if (_lineEraser == null) {
                              _lineEraser = LineEraser(
                                  lineStart!,
                                  vm.Vector2(event.localPosition.dx - offset.dx,
                                      event.localPosition.dy - offset.dy));
                            } else {
                              _lineEraser!.nextPoint(
                                  event.localPosition.dx - offset.dx,
                                  event.localPosition.dy - offset.dy);
                            }
                            bool hasRemoved = false;
                            for (int i = _paintElements!.length - 1;
                                i >= 0;
                                i--) {
                              if (_paintElements![i]
                                  .intersectAsSegments(_lineEraser!)) {
                                _paintElements!.removeAt(i);
                                hasRemoved = true;
                              }
                            }
                            if (hasRemoved) {
                              setState(() {});
                            }
                          } else if (canvasState == CanvasState.form) {
                            if (Forms.line == selectedForm) {
                              setState(() {
                                if (_lineForm == null) {
                                  _lineForm = LineForm(
                                      vm.Vector2(
                                          event.localPosition.dx - offset.dx,
                                          event.localPosition.dy - offset.dy),
                                      vm.Vector2(
                                          event.localPosition.dx - offset.dx,
                                          event.localPosition.dy - offset.dy),
                                      paint);
                                  print("Line Form was null");
                                } else {
                                  _lineForm!.setEndpoint(
                                      event.localPosition.dx - offset.dx,
                                      event.localPosition.dy - offset.dy);
                                  print("Line Form was not null");
                                }
                              });
                            }
                          }
                        },
                        onPointerUp: (event) {
                          _pointerMap.remove(event.pointer);
                          if (canvasState == CanvasState.zoom &&
                              _pointerMap.isEmpty) {
                            canvasState = CanvasState.pan;
                          }
                          if (canvasState == CanvasState.draw) {
                            if (_currentLine != null) {
                              if (_currentLine!.fragments.length > 1) {
                                setState(() {
                                  _paintElements!.add(_currentLine!);
                                  _currentLine = null;
                                });
                              } else if (_currentLine!.fragments.length == 1) {
                                setState(() {
                                  _paintElements!.add(Point(
                                      event.localPosition.dx - offset.dx,
                                      event.localPosition.dy - offset.dy,
                                      paint));
                                  _currentLine = null;
                                  print("Added a Point");
                                });
                              }
                            } else if (lineStart != null) {
                              setState(() {
                                _paintElements!.add(Point(
                                    event.localPosition.dx - offset.dx,
                                    event.localPosition.dy - offset.dy,
                                    paint));
                                print("Added a Point2");
                              });
                            }
                          } else if (canvasState == CanvasState.form) {
                            if (Forms.line == selectedForm) {
                              if (_lineForm != null) {
                                _lineForm!.setEndpoint(
                                    event.localPosition.dx - offset.dx,
                                    event.localPosition.dy - offset.dy);
                                setState(() {
                                  if (_lineForm!.isLineAPoint()) {
                                    _paintElements!.add(Point(
                                        _lineForm!.a.x, _lineForm!.a.y, paint));
                                    print("Added a Point from LineForm");
                                  } else {
                                    _paintElements!.add(_lineForm!);
                                    _lineForm = null;
                                    print("Added a Line Form");
                                  }
                                });
                                _lineForm = null;
                              } else {
                                print("Line form is null");
                              }
                            }
                          }
                          // setState(() {})
                        },
                        //TODO Test Scrollview
                        child: SizedBox.expand(
                          child: ClipRRect(
                            child: CustomPaint(
                              foregroundPainter: CanvasCustomPainter(
                                  _paintElements!,
                                  _currentLine,
                                  _lineForm,
                                  offset,
                                  paint),
                              // painter: BackgroundPainter(offset),
                              willChange: true,
                              child: CustomPaint(
                                painter: BackgroundPainter(
                                    offset, selectedBackground),
                                willChange: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ),
                    ))
                  ],
                ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  Offset offset;
  Background background;
  BackgroundPainter(this.offset, this.background);
  final int lineDistance = 20;
  final int checkeredDistance = 20;
  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()..color = Colors.black;
    if (background == Background.white) {
      return;
    } else if (background == Background.black) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    } else if (background == Background.checkered) {
      for (int i = 0; i < size.width; i += checkeredDistance) {
        canvas.drawLine(
            Offset(i.toDouble(), -checkeredDistance.toDouble()) +
                offset % checkeredDistance.toDouble(),
            Offset(i.toDouble(), size.height) +
                offset % checkeredDistance.toDouble(),
            backgroundPaint);
      }
      for (int i = 0; i < size.height; i += checkeredDistance) {
        canvas.drawLine(
            Offset(-checkeredDistance.toDouble(), i.toDouble()) +
                offset % checkeredDistance.toDouble(),
            Offset(size.width, i.toDouble()) +
                offset % checkeredDistance.toDouble(),
            backgroundPaint);
      }
    } else if (background == Background.lines) {
      for (int i = 0; i < size.height; i += lineDistance) {
        canvas.drawLine(
            Offset(-lineDistance.toDouble(), i.toDouble()) +
                offset % lineDistance.toDouble(),
            Offset(size.width, i.toDouble()) + offset % lineDistance.toDouble(),
            backgroundPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    // return true;
    //TODO: Always repaints for now.
    // return false;
    // print("Offset: " + offset.toString());
    // print("OldOffset: " + oldDelegate.offset.toString());
    if (oldDelegate.offset == offset && oldDelegate.background == background) {
      // print("OldOffset == Offset");
      return false;
    } else {
      return true;
    }
  }
}

class BackgroundPreview extends CustomPainter {
  Background background;
  BackgroundPreview(this.background);
  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()..color = Colors.black;
    if (background == Background.white) {
      return;
    } else if (background == Background.black) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    } else if (background == Background.checkered) {
      for (int i = 0; i < size.width; i += 10) {
        canvas.drawLine(Offset(i.toDouble(), 0),
            Offset(i.toDouble(), size.height), backgroundPaint);
      }
      for (int i = 0; i < size.height; i += 10) {
        canvas.drawLine(Offset(0, i.toDouble()),
            Offset(size.width, i.toDouble()), backgroundPaint);
      }
    } else if (background == Background.lines) {
      for (int i = 0; i < size.height; i += 10) {
        canvas.drawLine(Offset(0, i.toDouble()),
            Offset(size.width, i.toDouble()), backgroundPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPreview oldDelegate) {
    return false;
  }
}

class CanvasCustomPainter extends CustomPainter {
  final Line? _currentDrawingLine;

  final List<PaintElement> _paintElements;
  Offset offset;
  final Paint _drawingPaint;
  int paintElementsCount = 0;
  LineForm? _lineForm;

  CanvasCustomPainter(this._paintElements, this._currentDrawingLine,
      this._lineForm, this.offset, this._drawingPaint);

  @override
  void paint(Canvas canvas, Size size) {
    paintElementsCount = _paintElements.length;
    //define canvas background color
    // Paint background = Paint()..color = Colors.transparent;

    //define canvas size
    // Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // canvas.drawRect(rect, background);
    // canvas.clipRect(rect);

    for (final paintElement in _paintElements) {
      paintElement.draw(canvas, offset, size.width, size.height);
    }

    if (_currentDrawingLine != null) {
      _currentDrawingLine!.draw(canvas, offset, size.width, size.height);
    }

    if (_lineForm != null) {
      _lineForm!.draw(canvas, offset, size.width, size.height);
    }
  }

  @override
  bool shouldRepaint(CanvasCustomPainter oldDelegate) {
    return true;
    // if (oldDelegate.paintElementsCount != _paintElements.length ||
    //     oldDelegate.offset != offset) {
    //   print("Should Repaint 1");
    //   return true;
    // } else {
    //   if (oldDelegate._currentDrawingLine != null &&
    //       _currentDrawingLine != null) {
    //     if (oldDelegate._currentDrawingLine!.equals(_currentDrawingLine!)) {
    //       print("Should Repaint 2");
    //       return true;
    //     }
    //   }
    //   print("Should not Repaint: " +
    //       oldDelegate._paintElements.length.toString() +
    //       " " +
    //       _paintElements.length.toString() +
    //       " " +
    //       oldDelegate.offset.toString() +
    //       " " +
    //       offset.toString());
    //   print("Count: " +
    //       paintElementsCount.toString() +
    //       " " +
    //       _paintElements.length.toString());
    //   return false;
    // }
  }
}

// class OnlyOnePointerRecognizer extends OneSequenceGestureRecognizer {
//   int _p = 0;

//   @override
//   void addPointer(PointerDownEvent event) {
//     startTrackingPointer(event.pointer);

//     if (_p == 0) {
//       resolve(GestureDisposition.rejected);
//       _p = event.pointer;
//     } else {
//       resolve(GestureDisposition.accepted);
//     }
//   }

//   @override
//   String get debugDescription => 'only one pointer recognizer';

//   @override
//   void didStopTrackingLastPointer(int pointer) {}

//   @override
//   void handleEvent(PointerEvent event) {
//     if (!event.down && event.pointer == _p) {
//       _p = 0;
//     }
//   }
// }

// class OnlyOnePointerRecognizerWidget extends StatelessWidget {
//   final Widget? child;

//   OnlyOnePointerRecognizerWidget({this.child});

//   @override
//   Widget build(BuildContext context) {
//     return RawGestureDetector(gestures: <Type, GestureRecognizerFactory>{
//       OnlyOnePointerRecognizer:
//           GestureRecognizerFactoryWithHandlers<OnlyOnePointerRecognizer>(
//               () => OnlyOnePointerRecognizer(),
//               (OnlyOnePointerRecognizer instance) {})
//     }, child: child);
//   }
// }

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

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> getLocalFile(String notebookname) async {
  final path = await _localPath;
  return File('$path/$notebookname.json');
}
