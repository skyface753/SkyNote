import 'package:skynote/main.dart';
import 'package:skynote/models/base_paint_element.dart';

class NoteBook {
  String name;
  List<NoteSection> sections = [];
  int? selectedSectionIndex;
  int? selectedNoteIndex;
  Background defaultBackground;

  NoteBook(this.name, this.defaultBackground);

  addSection(NoteSection section) {
    sections.add(section);
  }

  removeSection(NoteSection section) {
    sections.remove(section);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sections': sections.map((section) => section.toJson()).toList(),
      'selectedSectionIndex': selectedSectionIndex,
      'selectedNoteIndex': selectedNoteIndex,
      'defaultBackground': backgroundToJson(defaultBackground),
    };
  }

  NoteBook.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        sections = List<NoteSection>.from(
            json['sections'].map((section) => NoteSection.fromJson(section))),
        selectedSectionIndex = json['selectedSectionIndex'],
        selectedNoteIndex = json['selectedNoteIndex'],
        defaultBackground = backgroundFromJson(json['defaultBackground']);
}

enum Background { white, lines, checkered, black }

Background backgroundFromJson(String json) {
  switch (json) {
    case 'white':
      return Background.white;
    case 'lines':
      return Background.lines;
    case 'checkered':
      return Background.checkered;
    case 'black':
      return Background.black;
    default:
      throw Exception('Unknown background: $json');
  }
}

String backgroundToJson(Background background) {
  switch (background) {
    case Background.white:
      return 'white';
    case Background.lines:
      return 'lines';
    case Background.checkered:
      return 'checkered';
    case Background.black:
      return 'black';
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

  NoteSection.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        notes =
            List<Note>.from(json['notes'].map((note) => Note.fromJson(note)));
}

class Note {
  String name;
  List<PaintElement> elements = [];

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
    };
  }

  Note.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        elements = PaintElement.fromJson(json['elements']);
}
