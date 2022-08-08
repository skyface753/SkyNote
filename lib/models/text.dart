import 'package:flutter/material.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class TextElement extends PaintElement {
  String text;
  vm.Vector2 pos;
  TextElement(this.text, this.pos, Paint paint) : super(paint);

  Widget showText() {
    return Text(
      text,
      style: TextStyle(fontSize: 17, color: paint.color),
    );
  }

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double width,
      double height,
      bool disableGestureDetection,
      VoidCallback refreshFromElement) {
    // disableGestureDetection = false;
    if (disableGestureDetection) {
      return (Positioned(
        left: pos.x + offset.dx,
        top: pos.y + offset.dy,
        child: showText(),
      ));
    } else {
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
                    title: Text('Edit text'),
                    content: TextField(
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
                        child: Text('Ok'),
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
              pos = vm.Vector2(
                  pos.x + details.delta.dx, pos.y + details.delta.dy);
              refreshFromElement();
            },
            onPanEnd: (DragEndDetails details) {
              // Position to a mod 20
              pos.y = (pos.y / 20).round() * 20 + 3;
              // pos.x = pos.x %
              refreshFromElement();
            },
            child: showText()),
      ));
    }
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    return false;
  }

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
        pos = vm.Vector2(json['posX'], json['posY']),
        super(paintConverter.paintFromJson(json['paint']));
}