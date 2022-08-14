import 'dart:math';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/selections/lasso_selection.dart';
import 'package:skynote/models/line_eraser.dart';
import 'dart:ui' as ui show Paint;

import 'package:skynote/models/point.dart';
import 'package:skynote/models/selections/selection_base.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

Storage appwriteCustomStorage = AppWriteCustom().getAppwriteStorage();

// Scale / 10 to get a better size for the image (Dont cover the whole screen)
const int initWHReducer = 10;

class PaintImage extends PaintElement {
  String appwriteFileId;
  vm.Vector2 a;
  Uint8List? _imageData;
  double width;
  double height;
  String? error;

  PaintImage(this.appwriteFileId, this.a, ui.Paint paint, this.width,
      this.height, VoidCallback refreshPaintWidget)
      : super(paint) {
    width = (width / initWHReducer);
    height = (height / initWHReducer);
    downloadImage(refreshPaintWidget);
  }

  Offset? startPointDragAndDrop;

  @override
  Widget? build(
      BuildContext context,
      Offset offset,
      double screenWidth,
      double screenHeight,
      VoidCallback refreshFromElement,
      ValueChanged<String> onDeleteImage) {
    if (_imageData == null) {
      if (error == null) {
        return Positioned(
          left: offset.dx + a.x,
          top: offset.dy + a.y,
          child: SizedBox(
            width: width,
            height: height,
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
            width: width,
            height: height,
            child: Center(
              child: Text(error!),
            ),
          ),
        );
      }
    }
    return StatefulBuilder(builder: (context, setState) {
      return Positioned(
        left: offset.dx + a.x,
        top: offset.dy + a.y,
        child: Stack(
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
              onDoubleTap: () {
                print("Double Tap an image");
                context.pushTransparentRoute(ImagePage(_imageData!));
              },
              child: Image.memory(_imageData!, width: width, height: height),
            ),
            Container(
              height: 10,
              width: 10,
              color: Colors.red,
              // Scaling the image
              child: GestureDetector(
                onPanUpdate: (details) {
                  Offset currentPosition = details.globalPosition;
                  var widthAtoCurrent = currentPosition.dx - a.x;
                  var heightAtoCurrent = currentPosition.dy - a.y;

                  print(
                      "widthAtoCurrent: $widthAtoCurrent heightAtoCurrent: $heightAtoCurrent");
                  setState(() {
                    width = widthAtoCurrent;
                    height = heightAtoCurrent;
                  });

                  // var newWidth =
                  //     width + (currentPosition.dx - startPointScale!.dx);
                  // var newHeight =
                  //     height + (currentPosition.dy - startPointScale!.dy);
                  // print(
                  //     "old width: $width, old height: $height new width: $newWidth, new height: $newHeight");

                  // if (newWidth < 10) {
                  //   newWidth = 10;
                  // }
                  // if (newHeight < 10) {
                  //   newHeight = 10;
                  // }

                  // // setState(() {
                  // width = newWidth;
                  // height = newHeight;
                  // });
                  // Adjust the height to keep the aspect ratio
                  // newHeight = newWidth / aspectRatio;
                  // if (newWidth > newHeight) {
                  //   newHeight = newWidth / aspectRatio;
                  // } else {
                  //   newWidth = newHeight * aspectRatio;
                  // }

                  // setState(() {
                  //   vm.Vector2 currentPoint = vm.Vector2(
                  //       details.localPosition.dx,
                  //       details.localPosition.dy);
                  //   var aspectRatio = width / height;
                  //   var newWidth =
                  //       width + (currentPoint.x - a.x) * aspectRatio;
                  //   var newHeight =
                  //       height + (currentPoint.y - a.y) * aspectRatio;
                  //   width = newWidth;
                  //   height = newHeight;
                  // });
                },
                child: Container(color: Colors.yellow, width: 10, height: 10),
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
  bool checkSelection(SelectionBase selection) {
    vm.Vector2 a2 = vm.Vector2(a.x + width, a.y);
    vm.Vector2 b = vm.Vector2(a.x, a.y + height);
    vm.Vector2 b2 = vm.Vector2(a.x + width, a.y + height);

    if (selection.checkCollision(a) &&
        selection.checkCollision(a2) &&
        selection.checkCollision(b) &&
        selection.checkCollision(b2)) {
      return true;
    }
    return false;
  }

  @override
  double getBottomY() {
    return a.y + height;
  }

  @override
  double getLeftX() {
    return a.x;
  }

  @override
  double getRightX() {
    return a.x + width;
  }

  @override
  double getTopY() {
    return a.y;
  }

  @override
  void moveByOffset(Offset offset) {
    a.x += offset.dx;
    a.y += offset.dy;
  }
}

class ImagePage extends StatelessWidget {
  final Uint8List _imageData;

  ImagePage(this._imageData);

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: false,
      child: Hero(
        tag: 'Unique tag',
        child: Image.memory(
          _imageData,
        ),
      ),
    );
  }
}
