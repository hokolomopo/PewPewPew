import 'package:flutter/material.dart';

import 'drawer_abstracts.dart';
import 'paint_constants.dart';

class BackgroundDrawer extends ImagedDrawer {
  BackgroundDrawer(size, {imgPath = defaultBackgroundPath})
      : super(size, imgPath);

  @override
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    canvas.drawImage(fetchNextFrame(), Offset.zero, Paint());
  }
}
