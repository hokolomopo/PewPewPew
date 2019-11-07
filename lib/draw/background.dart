import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'level.dart';
import 'paint_constants.dart';

class BackgroundDrawer extends CustomDrawer {
  Uint8List backgroundImgBytes;
  ui.Image toPaint;
  Size screenSize;

  BackgroundDrawer({imgPath = defaultBackgroundPath}) {
    setBackgroundImg(imgPath);
  }

  setBackgroundImg(String imgPath) async {
    ByteData bytes = await rootBundle.load(imgPath);
    backgroundImgBytes = bytes.buffer.asUint8List();
  }

  _reloadBackground(Size screenSize) async {
    ui.Codec codec = await ui.instantiateImageCodec(backgroundImgBytes,
        targetWidth: screenSize.width.toInt(),
        targetHeight: screenSize.height.toInt());
    toPaint = (await codec.getNextFrame()).image;

    this.screenSize = screenSize;
    repaint.notifyListeners();
  }

  @override
  bool isReady(Size screenSize) {
    if (this.screenSize != screenSize) {
      _reloadBackground(screenSize);
      return false;
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size, showHitBoxes) {
    canvas.drawImage(toPaint, Offset.zero, Paint());
  }
}
