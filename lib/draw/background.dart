import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/Cst.dart';
import 'dart:ui' as ui;

import 'level.dart';

class BackgroundDrawer extends CustomDrawer {
  Uint8List backgroundImgBytes;
  ui.Image toPaint;
  Size screenSize;

  BackgroundDrawer({imgPath = defaultBackgroundPath}) {
    setBackgroundImg(imgPath);
  }

  setBackgroundImg(String imgPath) async {
    ByteData bytes = await rootBundle
        .load(imgPath);
    backgroundImgBytes = bytes.buffer.asUint8List();
  }

  _reloadBackground() async {
    ui.Codec codec = await ui.instantiateImageCodec(backgroundImgBytes,
        targetWidth: screenSize.width.toInt(),
        targetHeight: screenSize.height.toInt());
    toPaint = (await codec.getNextFrame()).image;
    repaint.notifyListeners();
  }

  @override
  bool isReady(Size screenSize) {
    if (this.screenSize != screenSize) {
      this.screenSize = screenSize;
      _reloadBackground();
      return false;
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(toPaint, Offset.zero, Paint());
  }
}
