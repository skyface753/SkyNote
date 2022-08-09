import 'dart:math';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/lasso_selection.dart';
import 'package:skynote/models/line_eraser.dart';
import 'dart:ui' as ui show Paint;

import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

Storage appwriteCustomStorage = AppWriteCustom().getAppwriteStorage();

// Scale / 10 to get a better size for the image (Dont cover the whole screen)
// const int initWHReducer = 10;

class PaintImage extends PaintElement {
  String appwriteFileId;
  vm.Vector2 a;
  Uint8List? _imageData;
  int width;
  int height;
  double scale = 10;
  String? error;

  PaintImage(this.appwriteFileId, this.a, ui.Paint paint, this.width,
      this.height, VoidCallback refreshPaintWidget)
      : super(paint) {
    // width = (width / initWHReducer).round();
    // height = (height / initWHReducer).round();
    downloadImage(refreshPaintWidget);
  }

  Offset? startPointDragAndDrop;

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double screenWidth,
      double screenHeight,
      bool disableGestureDetection,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    if (_imageData == null) {
      if (error == null) {
        return Positioned(
          left: offset.dx + a.x,
          top: offset.dy + a.y,
          child: SizedBox(
            width: width / scale,
            height: height / scale,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      } else {
        return Positioned(
          left: offset.dx + a.x,
          top: offset.dy + a.y,
          child: SizedBox(
            width: width / scale,
            height: height / scale,
            child: Center(
              child: Text(error!),
            ),
          ),
        );
      }
    }
    double diagoLength =
        sqrt(pow(width, 2) + pow(height, 2)); // * initWHReducer;
    print("diagoLength: $diagoLength");
    return StatefulBuilder(builder: (context, setState) {
      return Positioned(
        left: offset.dx + a.x,
        top: offset.dy + a.y,
        child: disableGestureDetection
            ? Image.memory(_imageData!, scale: scale)
            : Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              a.x, a.y, screenWidth - a.x, screenHeight - a.y),
                          items: [
                            const PopupMenuItem(
                              value: 'delete',
                              child: const Text('Delete'),
                            ),
                          ]).then((value) {
                        if (value == 'delete') {
                          onDeleteImage(appwriteFileId);
                          refreshFromElement();
                        }
                      });
                    },
                    onPanStart: (details) {
                      startPointDragAndDrop = details.localPosition;
                    },
                    onPanUpdate: (details) {
                      if (startPointDragAndDrop == null) {
                        return;
                      }
                      print("Drag and drop");
                      double dx =
                          details.localPosition.dx - startPointDragAndDrop!.dx;
                      double dy =
                          details.localPosition.dy - startPointDragAndDrop!.dy;
                      setState(() {
                        a = vm.Vector2(a.x + dx, a.y + dy);
                      });
                      startPointDragAndDrop = details.localPosition;
                    },
                    onPanEnd: (details) {
                      startPointDragAndDrop = null;
                    },
                    child: Image.memory(_imageData!, scale: scale),
                  ),
                  Container(
                    height: 10,
                    width: 10,
                    color: Colors.red,
                    // Scaling the image
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        //TODO
                        // print("Scale");
                        setState(() {
                          double deltaCurrent = sqrt(pow(
                                  (a.x + offset.dx) - details.globalPosition.dx,
                                  2) +
                              pow((a.y + offset.dy) - details.globalPosition.dy,
                                  2));
                          double testScale = (diagoLength / (deltaCurrent));
                          scale = (num.parse(testScale.toStringAsFixed(2)))
                              .toDouble();
                          print(
                              "deltaCurrent: $deltaCurrent deltaOriginal: $diagoLength testScale: $scale");
                          // scale = min(max(scale + details.delta.dy, 1), 100);
                          // scale -= details.delta.dy;
                        });
                      },
                      child: Container(
                          color: Colors.yellow, width: 10, height: 10),
                    ),
                  )
                ],
              ),
      );
    });

    // a = oben Links
    // a2 = oben Rechts
    // b = unten Links
    // b2 = unten Rechts
    print("Refresh paint image");
    // double imageWidth = width.toDouble();
    // double imageHeight = height.toDouble();
    // RECT of image
    vm.Vector2 a2 = vm.Vector2(a.x + width, a.y);
    vm.Vector2 b = vm.Vector2(a.x, a.y + height);
    vm.Vector2 b2 = vm.Vector2(a2.x, b.y);

    bool aInBounds = (-offset.dx <= a.x &&
        a.x <= -offset.dx + screenWidth &&
        -offset.dy <= a.y &&
        a.y <= -offset.dy + screenHeight);
    bool a2InBounds = (-offset.dx <= a2.x &&
        a2.x <= -offset.dx + screenWidth &&
        -offset.dy <= a2.y &&
        a2.y <= -offset.dy + screenHeight);
    bool bInBounds = (-offset.dx <= b.x &&
        b.x <= -offset.dx + screenWidth &&
        -offset.dy <= b.y &&
        b.y <= -offset.dy + screenHeight);
    bool b2InBounds = (-offset.dx <= b2.x &&
        b2.x <= -offset.dx + screenHeight &&
        -offset.dy <= b2.y &&
        b2.y <= -offset.dy + screenHeight);
    if (aInBounds || a2InBounds || bInBounds || b2InBounds) {
      if (_imageData == null) {
        return Positioned(
          left: offset.dx + a.x,
          top: offset.dy + a.y,
          child: SizedBox(
            width: width.toDouble() * scale,
            height: height.toDouble() * scale,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      } else {
        return StatefulBuilder(builder: (context, setState) {
          return Positioned(
            left: offset.dx + a.x,
            top: offset.dy + a.y,
            child: disableGestureDetection
                ? Image.memory(_imageData!, scale: 0.2)
                : Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onPanStart: (details) {
                          startPointDragAndDrop = details.localPosition;
                        },
                        onPanUpdate: (details) {
                          if (startPointDragAndDrop == null) {
                            return;
                          }
                          print("Drag and drop");
                          double dx = details.localPosition.dx -
                              startPointDragAndDrop!.dx;
                          double dy = details.localPosition.dy -
                              startPointDragAndDrop!.dy;
                          setState(() {
                            a = vm.Vector2(a.x + dx, a.y + dy);
                            a2 = vm.Vector2(a2.x + dx, a2.y + dy);
                            b = vm.Vector2(b.x + dx, b.y + dy);
                            b2 = vm.Vector2(b2.x + dx, b2.y + dy);
                          });
                          startPointDragAndDrop = details.localPosition;
                        },
                        onPanEnd: (details) {
                          startPointDragAndDrop = null;
                        },
                        child: Image.memory(_imageData!, scale: scale),
                      ),
                      Container(
                        height: 10,
                        width: 10,
                        color: Colors.red,
                        // Scaling the image
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            // print("Scale");
                            // B2 = unten Rechts
                            // print("dx: ${details.localPosition.dx}");
                            //TODO !!!!!
                            double currX =
                                details.globalPosition.dx - offset.dx;
                            double currY =
                                details.globalPosition.dy - offset.dy;
                            double diagoPos =
                                sqrt(pow(currX - a.x, 2) + pow(currY - a.y, 2));
                            double diagoOrig =
                                sqrt(pow(a.x - b2.x, 2) + pow(a.y - b2.y, 2));
                            print("diagoPos: $diagoPos diagoOrig: $diagoOrig");
                            scale = diagoPos / diagoOrig;
                            print("scale: $scale");
                            // double newWidth = sqrt(pow(currX - a.x, 2));
                            // double newHeight = sqrt(pow(currY - a.y, 2));
                            // print("a.x ${a.x} currX: $currX currY: $currY newWidth: $newWidth newHeight: $newHeight");
                            setState(() {});
                          },
                          child: Container(
                              color: Colors.yellow, width: 10, height: 10),
                        ),
                      )
                    ],
                  ),
          );
        });
      }
    }
    return null;
  }

  void downloadImage(VoidCallback callback) async {
    try {
      Uint8List fileBytes = await appwriteCustomStorage.getFileDownload(
          bucketId: '62e40e4e2d262cc2e179', fileId: appwriteFileId);
      _imageData = fileBytes;
      // final ui.Codec codec = await ui.instantiateImageCodec(fileBytes);

      // final ui.Image image = (await codec.getNextFrame()).image;
      // this.image = image;
      print("Image downloaded and setted");
      callback();
    } catch (e) {
      error = "Error downloading image";
      callback();
    }
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    //Dont delete Image
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.paintImage.index,
      'appwriteFileId': appwriteFileId,
      'aX': a.x,
      'aY': a.y,
      'width': width,
      'height': height,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  PaintImage.fromJson(Map<String, dynamic> json, VoidCallback imageLoadCallback)
      : appwriteFileId = json['appwriteFileId'],
        a = vm.Vector2(json['aX'], json['aY']),
        width = json['width'] ?? 100,
        height = json['height'] ?? 100,
        super(paintConverter.paintFromJson(json['paint'])) {
    downloadImage(imageLoadCallback);
  }

  @override
  bool checkLassoSelection(LassoSelection lassoSelection) {
    vm.Vector2 a2 = vm.Vector2(a.x + (width / scale), a.y);
    vm.Vector2 b = vm.Vector2(a.x, a.y + (height / scale));
    vm.Vector2 b2 = vm.Vector2(a.x + (width / scale), a.y + (height / scale));

    if (lassoSelection.checkCollision(a) &&
        lassoSelection.checkCollision(a2) &&
        lassoSelection.checkCollision(b) &&
        lassoSelection.checkCollision(b2)) {
      return true;
    }
    return false;
  }

  @override
  double getBottomY() {
    return a.y + height / scale;
  }

  @override
  double getLeftX() {
    return a.x;
  }

  @override
  double getRightX() {
    return a.x + width / scale;
  }

  @override
  double getTopY() {
    return a.y;
  }

  @override
  void moveByOffset(Offset offset) {
    a.x += offset.dx;
    a.y += offset.dy;

    // TODO: implement moveByOffset
  }
}
