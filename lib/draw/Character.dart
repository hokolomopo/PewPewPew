import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/Cst.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'level.dart';

class CharacterDrawer extends CustomDrawer {
  Uint8List characterImgBytes;
  ui.Image characterImg;
  Size screenSize;
  double width;
  double height;
  Offset position;
  double life = 1.0;

  CharacterDrawer(String imgPath, this.position,
      {this.width = 0.1, this.height = 0.1}) {
    setImg(imgPath);
  }

  setImg(String imgPath) async {
    ByteData bytes = await rootBundle.load(imgPath);
    characterImgBytes = bytes.buffer.asUint8List();
  }

  decreaseLife(double loss) {
    this.life -= loss;
  }

  move(Offset displacement) {
    position += displacement;
  }

  _reloadImg(Size screenSize) async {
    ui.Codec codec = await ui.instantiateImageCodec(characterImgBytes,
        targetWidth: (width * screenSize.width).toInt(),
        targetHeight: (height * screenSize.height).toInt());
    characterImg = (await codec.getNextFrame()).image;

    this.screenSize = screenSize;
    repaint.notifyListeners();
  }

  @override
  bool isReady(Size screenSize) {
    if (this.screenSize != screenSize) {
      _reloadImg(screenSize);
      return false;
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double left = position.dx * size.width;
    double top = position.dy * size.height;
    double actualWidth = width * size.width;
    double actualHeight = height * size.height;

    canvas.drawImage(characterImg, Offset(left, top), Paint());

    double lifeBarTop = top - distanceLifeBarCharacter * size.height;
    Color lifeColor;
    if (life < 0.5) {
      lifeColor = Color.fromRGBO(
          (510 * (0.5 - life)).toInt(), (510 * life).toInt(), 0, 1.0);
    } else {
      lifeColor = Color.fromRGBO(
          0, (510 * (1 - life)).toInt(), (510 * (life - 0.5)).toInt(), 1.0);
    }
    Paint lifeBarPaint = Paint()
      ..color = lifeColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(left, lifeBarTop, actualWidth * life, actualHeight / 3),
        lifeBarPaint);
    canvas.drawRect(
        Rect.fromLTWH(left, lifeBarTop, actualWidth, actualHeight / 3),
        lifeBarStrokePaint);
  }
}
