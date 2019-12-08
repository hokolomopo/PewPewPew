import 'package:flutter/material.dart';

import 'level_painter.dart';
import 'paint_constants.dart';

class BackgroundDrawer extends CustomDrawer {
  BackgroundDrawer(size, {imgPath = defaultBackgroundPath})
      : super(size, imgPath);

  @override
  bool isReady(Size screenSize) {
    super.isReady(screenSize);
    return imgAndGif.containsKey(gifPath) &&
        imgAndGif[gifPath].containsKey(relativeSize) &&
        imgAndGif[gifPath][relativeSize] != null &&
        imgAndGif[gifPath][relativeSize].fetchNextFrame() != null;
  }

  @override
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    canvas.drawImage(fetchNextFrame(), Offset.zero, Paint());
  }
}
