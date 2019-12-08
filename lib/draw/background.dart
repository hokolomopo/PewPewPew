import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'level_painter.dart';
import 'paint_constants.dart';

class BackgroundDrawer extends CustomDrawer {
  Uint8List backgroundImgBytes;

  BackgroundDrawer(size, {imgPath = defaultBackgroundPath, screenSize})
      : super(size, imgPath, screenSize: screenSize);

  @override
  bool isReady2(Size screenSize) {
    super.isReady2(screenSize);
    return imgAndGif.containsKey(gifPath) &&
        imgAndGif[gifPath].containsKey(relativeSize) &&
        imgAndGif[gifPath][relativeSize] != null &&
        imgAndGif[gifPath][relativeSize].fetchNextFrame() != null;
  }

  @override
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    canvas.drawImage(fetchNextFrame2(), Offset.zero, Paint());
  }
}
