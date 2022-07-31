import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_eraser.dart';
import 'package:skynote/models/line_fragment.dart';
import 'dart:ui' as ui
    show
        Image,
        Paint,
        Canvas,
        Offset,
        decodeImageFromList,
        Codec,
        instantiateImageCodec;

import 'package:skynote/models/line_old.dart';
import 'package:skynote/models/point.dart';

Storage appwriteCustomStorage = AppWriteCustom().getAppwriteStorage();

class PaintImage extends PaintElement {
  String appwriteFileId;
  double x;
  double y;
  ui.Image? image;

  PaintImage(this.appwriteFileId, this.x, this.y, ui.Paint paint)
      : super(paint) {
    downloadImage();
  }

  @override
  void draw(ui.Canvas canvas, ui.Offset offset, double width, double height) {
    if (image == null) {
      Rect rect = Rect.fromLTWH(offset.dx + x, offset.dy + y, 100, 100);
      canvas.drawRect(rect, paint);
      return;
    }
    Rect rect = Rect.fromLTWH(offset.dx + x, offset.dy + y, 100, 100);
    paintImage(canvas: canvas, rect: rect, image: image!);
    // canvas.drawImage(image!, offset, paint);
  }

  void downloadImage() async {
    Uint8List fileBytes = await appwriteCustomStorage.getFileDownload(
        bucketId: '62e40e4e2d262cc2e179', fileId: appwriteFileId);
    final ui.Codec codec = await ui.instantiateImageCodec(fileBytes);

    final ui.Image image = (await codec.getNextFrame()).image;
    this.image = image;
    print("Image downloaded and setted");
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    return false;
    // TODO: implement intersectAsSegments
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'PaintImage',
      'appwriteFileId': appwriteFileId,
      'x': x,
      'y': y,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  PaintImage.fromJson(Map<String, dynamic> json)
      : appwriteFileId = json['appwriteFileId'],
        x = json['x'],
        y = json['y'],
        super(paintConverter.paintFromJson(json['paint'])) {
    downloadImage();
  }
}
