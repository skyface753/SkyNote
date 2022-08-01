import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/line_eraser.dart';
import 'dart:ui' as ui
    show Image, Paint, Canvas, Offset, Codec, instantiateImageCodec;

import 'package:skynote/models/point.dart';
import 'package:skynote/models/types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

Storage appwriteCustomStorage = AppWriteCustom().getAppwriteStorage();

class PaintImage extends PaintElement {
  String appwriteFileId;
  vm.Vector2 a;
  ui.Image? image;

  PaintImage(this.appwriteFileId, this.a, ui.Paint paint,
      VoidCallback refreshPaintWidget)
      : super(paint) {
    downloadImage(refreshPaintWidget);
  }

  @override
  void draw(ui.Canvas canvas, ui.Offset offset, double width, double height) {
    if (image == null) {
      Rect rect = Rect.fromLTWH(offset.dx + a.x, offset.dy + a.y, 100, 100);
      canvas.drawRect(rect, paint);
      return;
    }
    //TODO Replace with dynamic width and height
    double imageWidth = 100;
    double imageHeight = 100;
    // a = oben Links
    // a2 = oben Rechts
    // b = unten Links
    // b2 = unten Rechts
    vm.Vector2 a2 = vm.Vector2(a.x + imageWidth, a.y);
    vm.Vector2 b = vm.Vector2(a.x, a.y + imageHeight);
    vm.Vector2 b2 = vm.Vector2(a2.x, b.y);
    bool aInBounds = (-offset.dx <= a.x &&
        a.x <= -offset.dx + width &&
        -offset.dy <= a.y &&
        a.y <= -offset.dy + height);
    bool a2InBounds = (-offset.dx <= a2.x &&
        a2.x <= -offset.dx + width &&
        -offset.dy <= a2.y &&
        a2.y <= -offset.dy + height);
    bool bInBounds = (-offset.dx <= b.x &&
        b.x <= -offset.dx + width &&
        -offset.dy <= b.y &&
        b.y <= -offset.dy + height);
    bool b2InBounds = (-offset.dx <= b2.x &&
        b2.x <= -offset.dx + width &&
        -offset.dy <= b2.y &&
        b2.y <= -offset.dy + height);
    if (aInBounds || a2InBounds || bInBounds || b2InBounds) {
      Rect rect = Rect.fromLTWH(offset.dx + a.x, offset.dy + a.y, 100, 100);
      paintImage(canvas: canvas, rect: rect, image: image!);
    }
  }

  void downloadImage(VoidCallback callback) async {
    Uint8List fileBytes = await appwriteCustomStorage.getFileDownload(
        bucketId: '62e40e4e2d262cc2e179', fileId: appwriteFileId);
    final ui.Codec codec = await ui.instantiateImageCodec(fileBytes);

    final ui.Image image = (await codec.getNextFrame()).image;
    this.image = image;
    print("Image downloaded and setted");
    callback();
  }

  @override
  bool intersectAsSegments(LineEraser lineEraser) {
    //Dont delete Image
    return false;
    // TODO: implement intersectAsSegments
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': PaintElementTypes.paintImage.index,
      'appwriteFileId': appwriteFileId,
      'aX': a.x,
      'aY': a.y,
      'paint': paintConverter.paintToJson(paint),
    };
  }

  PaintImage.fromJson(Map<String, dynamic> json, VoidCallback imageLoadCallback)
      : appwriteFileId = json['appwriteFileId'],
        a = vm.Vector2(json['aX'], json['aY']),
        super(paintConverter.paintFromJson(json['paint'])) {
    downloadImage(imageLoadCallback);
  }
}
