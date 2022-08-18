import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/point.dart';

const double defaultStroke = 2;
List<Paint> getDefaultPaints() {
  return [
    Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = defaultStroke
      ..strokeCap = StrokeCap.round,
    Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = defaultStroke
      ..strokeCap = StrokeCap.round,
    Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.green
      ..strokeWidth = defaultStroke
      ..strokeCap = StrokeCap.round,
  ];
}

List<Paint> paintsFromJson(String json) {
  final jsonDecoded = jsonDecode(json);
  return jsonDecoded.map((paint) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(int.parse(paint['color']))
      ..strokeWidth = double.parse(paint['strokeWidth'])
      ..strokeCap = StrokeCap.round;
  }).toList();
}

class NoteBook {
  String? appwriteFileId;
  String name;
  List<NoteSection> sections = [];
  List<Paint> paints = getDefaultPaints();
  int selectedPencilIndex = 0;
  int? selectedSectionIndex;
  int? selectedNoteIndex;
  bool darkMode = false;
  // Background defaultBackground = Background.lines;

  NoteBook(this.name);

  // Set appwriteFileId
  void setAppwriteFileId(String appwriteFileId) {
    this.appwriteFileId = appwriteFileId;
  }

  addSection(NoteSection section) {
    sections.add(section);
  }

  removeSection(NoteSection section) {
    sections.remove(section);
  }

  Map<String, dynamic> toJson() {
    return {
      'appwriteFileId': appwriteFileId,
      'name': name,
      'sections': sections.map((section) => section.toJson()).toList(),
      'selectedSectionIndex': selectedSectionIndex,
      'selectedNoteIndex': selectedNoteIndex,
      'paints': paintConverter.paintsListToJson(paints),
      'selectedPencilIndex': selectedPencilIndex,
      'darkMode': darkMode,
      // 'defaultBackground': backgroundToJson(defaultBackground),
    };
  }

  NoteBook.fromJson(Map<String, dynamic> json, VoidCallback imageLoadCallback)
      : appwriteFileId = json['appwriteFileId'],
        name = json['name'],
        sections = List<NoteSection>.from(json['sections'].map(
            (section) => NoteSection.fromJson(section, imageLoadCallback))),
        selectedSectionIndex = json['selectedSectionIndex'],
        selectedNoteIndex = json['selectedNoteIndex'],
        paints = paintConverter.paintsListFromJson(json['paints']),
        selectedPencilIndex = json['selectedPencilIndex'] ?? 0,
        darkMode = json['darkMode'] ?? false;

  @override
  toString() {
    return jsonEncode(toJson());
  }

  String getHash() {
    return sha512.convert(utf8.encode(toString())).toString();
  }
}

enum Background { none, lines, checkered }

Background backgroundFromJson(String json) {
  switch (json) {
    case 'none':
      return Background.none;
    case 'lines':
      return Background.lines;
    case 'checkered':
      return Background.checkered;
    default:
      throw Exception('Unknown background: $json');
  }
}

String backgroundToJson(Background background) {
  switch (background) {
    case Background.none:
      return 'none';
    case Background.lines:
      return 'lines';
    case Background.checkered:
      return 'checkered';
    default:
      throw Exception('Unknown background: $background');
  }
}

class NoteSection {
  String name;
  List<Note> notes = [];

  NoteSection(
    this.name,
  );

  addNote(Note note) {
    notes.add(note);
  }

  removeNote(Note note) {
    notes.remove(note);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'notes': notes.map((note) => note.toJson()).toList(),
    };
  }

  NoteSection.fromJson(
      Map<String, dynamic> json, VoidCallback imageLoadCallback)
      : name = json['name'],
        notes = List<Note>.from(json['notes']
            .map((note) => Note.fromJson(note, imageLoadCallback)));
}

class Note {
  String name;
  Offset? lastPos;
  List<PaintElement> elements = [];
  Background background = Background.lines;

  Note(
    this.name,
  );

  addElement(PaintElement element) {
    elements.add(element);
  }

  removeElement(PaintElement element) {
    elements.remove(element);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'elements': elements.map((element) => element.toJson()).toList(),
      'lastPos': lastPos != null
          ? {
              'x': lastPos?.dx,
              'y': lastPos?.dy,
            }
          : null,
      'background': backgroundToJson(background),
    };
  }

  Note.fromJson(Map<String, dynamic> json, VoidCallback paintImageCallback)
      : name = json['name'],
        elements = PaintElement.fromJson(json['elements'], paintImageCallback),
        lastPos = json['lastPos'] != null
            ? Offset(json['lastPos']['x'].toDouble(),
                json['lastPos']['y'].toDouble())
            : null,
        background = backgroundFromJson(json['background']);
}
