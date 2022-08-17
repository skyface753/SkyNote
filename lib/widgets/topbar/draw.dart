import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skynote/main.dart';

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
    case Forms.arrow:
      return 'arrow';
  }
}

class DrawTopBar extends StatelessWidget {
  final CanvasState canvasState;
  final Color selectedPaintColor;
  final Paint currentPaint;
  final List<double> strokeWidthItems;
  final List<Forms> formItems;
  final Forms selectedForm;
  final VoidCallback onChangeEraseMode;
  final ValueChanged<Color> onChangPaintColor;
  final ValueChanged<double> onChangeStrokeWidth;
  final ValueChanged<Forms> onChangeForm;
  final List<Paint> paints;
  final Paint selectedPaint;
  final ValueChanged<Paint> onChangePaint;

  DrawTopBar(
      this.canvasState,
      this.selectedPaintColor,
      this.currentPaint,
      this.strokeWidthItems,
      this.formItems,
      this.selectedForm,
      this.onChangeEraseMode,
      this.onChangPaintColor,
      this.onChangeStrokeWidth,
      this.onChangeForm,
      this.paints,
      this.selectedPaint,
      this.onChangePaint);

  @override
  Widget build(BuildContext context) {
    print("Paints COunt" + paints.length.toString());
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Eraser Button
        IconButton(
          icon: const Icon(Icons.delete),
          color: CanvasState.erase == canvasState ? Colors.red : Colors.black,
          onPressed: () {
            onChangeEraseMode();
          },
        ),
        DropdownButton(
          value: selectedPaintColor,
          items: colorItems.map(
            (color) {
              return DropdownMenuItem(
                value: color,
                child: ColoredBox(
                  color: color,
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                ),
              );
            },
          ).toList(),
          onChanged: (Color? color) {
            onChangPaintColor(color!);
          },
        ),
        DropdownButton(
          value: currentPaint.strokeWidth,
          items: strokeWidthItems
              .map(
                (strokeWidth) => DropdownMenuItem(
                    value: strokeWidth,
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(
                            child: CustomPaint(
                                painter: StrokeWidthPreview(strokeWidth))))
                    // Text(
                    //   '$strokeWidth',
                    //   style:
                    //       const TextStyle(fontSize: 20, color: Colors.black),
                    // ),
                    ),
              )
              .toList(),
          onChanged: (double? newValue) {
            onChangeStrokeWidth(newValue!);
          },
          dropdownColor: Colors.white,
        ),
        DropdownButton(
            items: formItems.map((form) {
              return DropdownMenuItem(
                  value: form,
                  child: Text(
                    _formsToString(form),
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ));
            }).toList(),
            value: selectedForm,
            onChanged: (Forms? newValue) {
              onChangeForm(newValue!);
            }),
        //Paints
        //TODO Default Selected Paint & Load from NoteBook
        ...PaintsButtons(context, paints, selectedPaint, onChangePaint),
      ],
    );
  }
}

List<Widget> PaintsButtons(BuildContext context, List<Paint> paints,
    Paint selectedPaint, ValueChanged<Paint> onChangePaint) {
  List<Widget> paintsButtons = [];
  for (int i = 0; i < paints.length; i++) {
    paintsButtons.add(
      SinglePaintButton(
        paints[i],
        selectedPaint,
        onChangePaint,
      ),
    );
  }
  return paintsButtons;
}

class SinglePaintButton extends StatelessWidget {
  final Paint paint;
  final Paint selectedPaint;
  final ValueChanged<Paint> onChangePaint;

  SinglePaintButton(this.paint, this.selectedPaint, this.onChangePaint);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: paint == selectedPaint
            ? Colors.black.withOpacity(0.5)
            : Colors.transparent,
        child: IconButton(
            icon: const Icon(Icons.brush),
            color: paint.color,
            onPressed: () {
              onChangePaint(paint);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Paint'),
                    content: SizedBox(
                        width: MediaQuery.of(context).size.width * .7,
                        // height: 1000,
                        // width: 1000,
                        // color: Colors.black,
                        child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 100,
                                    childAspectRatio: 3 / 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20),
                            itemCount: colorItems.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              return InkWell(
                                onTap: () {
                                  paint.color = colorItems[index];
                                  onChangePaint(paint);
                                  Navigator.pop(ctx);
                                  // onChangePaint(paint);
                                },
                                child: Container(
                                  color: colorItems[index],
                                  child: const SizedBox(
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              );
                            })),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }));
  }
}

class StrokeWidthPreview extends CustomPainter {
  final double strokeWidth;
  StrokeWidthPreview(this.strokeWidth);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, [const Offset(0, 0)], paint);
  }

  @override
  bool shouldRepaint(StrokeWidthPreview oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth;
  }
}

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
