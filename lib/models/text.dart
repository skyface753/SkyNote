import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/selections/lasso_selection.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

double fontSize = 10.5;

class TextElement extends PaintElement {
  String text;
  vm.Vector2 pos;
  TextElement(this.text, this.pos, Paint paint) : super(paint);

  Widget showText(
    bool isDarkMode,
  ) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          height: 0.95,
          color: isDarkMode && paint.color == Colors.black
              ? Colors.white
              : !isDarkMode && paint.color == Colors.white
                  ? Colors.black
                  : paint.color),
    );
  }

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool isDarkMode,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    return (Positioned(
      left: pos.x + offset.dx,
      top: pos.y + offset.dy,
      child: GestureDetector(
          onTap: () {
            // Show text input dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Edit text'),
                  content: TextField(
                    autofocus: true,
                    controller: TextEditingController(text: text),
                    onChanged: (String newText) {
                      text = newText;
                    },
                    onSubmitted: (String newText) {
                      text = newText;
                      refreshFromElement();
                      Navigator.of(context).pop();
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        refreshFromElement();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          onPanUpdate: (DragUpdateDetails details) {
            pos =
                vm.Vector2(pos.x + details.delta.dx, pos.y + details.delta.dy);
            refreshFromElement();
          },
          onPanEnd: (DragEndDetails details) {
            // Position to a mod 20
            pos.y = (pos.y / 10).round() * 10 + 2;
            // pos.x = pos.x %
            refreshFromElement();
          },
          child: showText(isDarkMode)),
    ));
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.textElement.index,
      'text': text,
      'posX': pos.x,
      'posY': pos.y,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  TextElement.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        pos = vm.Vector2(json['posX'].toDouble(), json['posY'].toDouble()),
        super(paintConverter.paintFromJson(json['paint']));

  @override
  double getBottomY() {
    var textHeight = _textHeight(text);
    return pos.y + textHeight;
  }

  @override
  double getLeftX() {
    return pos.x;
  }

  @override
  double getRightX() {
    var textWidth = _textWidth(text);
    return pos.x + textWidth;
  }

  @override
  double getTopY() {
    return pos.y;
  }

  @override
  void moveByOffset(Offset offset) {
    pos.x += offset.dx;
    pos.y += offset.dy;
  }

  @override
  bool checkSelection(SelectionBase selection) {
    var textWidth = _textWidth(text);
    var textHeight = _textHeight(text);
    vm.Vector2 topRight = vm.Vector2(pos.x + textWidth, pos.y);
    vm.Vector2 bottomLeft = vm.Vector2(pos.x, pos.y + textHeight);
    vm.Vector2 bottomRight = vm.Vector2(topRight.x, bottomLeft.y);
    if (selection.checkCollision(pos) &&
        selection.checkCollision(topRight) &&
        selection.checkCollision(bottomLeft) &&
        selection.checkCollision(bottomRight)) {
      return true;
    }
    return false;
  }
}

double _textWidth(String text) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.width;
}

double _textHeight(String text) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.height;
}
