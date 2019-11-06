import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/Cst.dart';
import 'package:info2051_2018/game/character.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'level.dart';

class CharacterDrawer extends CustomDrawer {
  Uint8List characterImgBytes;
  ui.Image characterImg;
  Size screenSize;
  double width;
  double height;

  Character character;

  CharacterDrawer(String imgPath, this.character,
      {this.width = 10, this.height = 10}) {
    setImg(imgPath);
  }

  setImg(String imgPath) async {
    ByteData bytes = await rootBundle.load(imgPath);
    characterImgBytes = bytes.buffer.asUint8List();
  }

  _reloadImg(Size screenSize) async {
    ui.Codec codec = await ui.instantiateImageCodec(characterImgBytes,
        targetWidth: (width / 100 * screenSize.height).toInt(),
        targetHeight: (height / 100 * screenSize.height).toInt());
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
    double left = character.position.dx * size.height;
    double top = character.position.dy * size.height;
    double actualWidth = width / 100 * size.height;
    double actualHeight = height / 100 * size.height;

    canvas.drawImage(characterImg, Offset(left, top), Paint());

    double lifeBarTop = top - distanceLifeBarCharacter * size.height;
    Color lifeColor;
    if (character.hp < 0.5) {
      lifeColor = Color.fromRGBO(
          (510 * (0.5 - character.hp)).toInt(), (510 * character.hp).toInt(), 0, 1.0);
    } else {
      lifeColor = Color.fromRGBO(
          0, (510 * (1 - character.hp)).toInt(), (510 * (character.hp - 0.5)).toInt(), 1.0);
    }
    Paint lifeBarPaint = Paint()
      ..color = lifeColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(left, lifeBarTop, actualWidth * character.hp, actualHeight / 3),
        lifeBarPaint);
    canvas.drawRect(
        Rect.fromLTWH(left, lifeBarTop, actualWidth, actualHeight / 3),
        lifeBarStrokePaint);
  }
}
