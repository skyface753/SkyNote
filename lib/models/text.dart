import 'package:flutter/material.dart';

class TextElement {
  String text;
  Offset positionOffset;
  bool editMode = false;

  TextElement(this.text, this.positionOffset);

  Widget getWidget(BuildContext context, Offset offset, bool listnerDisabled,
      VoidCallback onUpdate) {
    return AbsorbPointer(
        absorbing: listnerDisabled,
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            print('TextElement: onPointerDown');
          },
          // onTap: () => print("TextElement onTap"),
          // onPanUpdate: (details) {
          //   positionOffset =
          //       Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
          //   onUpdate();
          // },
          // child: SizedBox(
          //     width: 300,
          //     height: 300,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Center(
          child: Text("You Think You Are Funny But You Are Not",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.0,
                  color: Colors.red)),

          // ))
        ));
  }

  TextElement.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        positionOffset =
            Offset(json['positionOffset']['dx'], json['positionOffset']['dy']);

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'positionOffset': {'dx': positionOffset.dx, 'dy': positionOffset.dy},
    };
  }
}
