import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'level_painter.dart';
import 'paint_constants.dart';

class BackgroundDrawer extends CustomDrawer {
  Uint8List backgroundImgBytes;
  ui.Image toPaint;
  Size screenSize;
  Size levelSize;

  BackgroundDrawer(this.levelSize, {imgPath = defaultBackgroundPath}) {
    setBackgroundImg(imgPath);
  }

  setBackgroundImg(String imgPath) async {
    ByteData bytes = await rootBundle.load(imgPath);
    backgroundImgBytes = bytes.buffer.asUint8List();
  }

  _reloadBackground(Size screenSize) async {
    Offset absoluteLevelSize = GameUtils.relativeToAbsoluteOffset(GameUtils.getDimFromSize(levelSize),
        screenSize.height);

    ui.Codec codec = await ui.instantiateImageCodec(backgroundImgBytes,
        targetWidth: absoluteLevelSize.dx.toInt(),
        targetHeight: absoluteLevelSize.dy.toInt());
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
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    canvas.drawImage(toPaint, Offset.zero, Paint());
  }
}
