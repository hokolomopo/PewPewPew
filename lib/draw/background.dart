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
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    ui.Image toPaint = fetchNextFrame();
    canvas.drawImage(toPaint, Offset.zero, Paint());
  }
}
