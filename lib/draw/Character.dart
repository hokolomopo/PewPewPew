import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'Cst.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/utils.dart';
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
        targetWidth:
            (GameUtils.relativeToAbsoluteDist(width, screenSize.height))
                .toInt(),
        targetHeight:
            (GameUtils.relativeToAbsoluteDist(height, screenSize.height))
                .toInt());
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
  void paint(Canvas canvas, Size size, showHitBoxes) {
    double left =
        GameUtils.relativeToAbsoluteDist(character.position.dx, size.height);
    double top =
        GameUtils.relativeToAbsoluteDist(character.position.dy, size.height);
    double actualWidth = GameUtils.relativeToAbsoluteDist(width, size.height);
    double actualHeight = GameUtils.relativeToAbsoluteDist(height, size.height);

    if (showHitBoxes) {
      canvas.drawRect(Rect.fromLTWH(left, top, actualWidth, actualHeight),
          debugShowHitBoxesPaint);
    }

    canvas.drawImage(characterImg, Offset(left, top), Paint());

    double lifeBarTop = top - distanceLifeBarCharacter * size.height;
    Color lifeColor;
    double normalizedHp = character.hp / Character.base_hp;
    if (normalizedHp < 0.5) {
      lifeColor = Color.fromRGBO((510 * (0.5 - normalizedHp)).toInt(),
          (510 * normalizedHp).toInt(), 0, 1.0);
    } else {
      lifeColor = Color.fromRGBO(0, (510 * (1 - normalizedHp)).toInt(),
          (510 * (normalizedHp - 0.5)).toInt(), 1.0);
    }
    Paint lifeBarPaint = Paint()
      ..color = lifeColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(
            left, lifeBarTop, actualWidth * normalizedHp, actualHeight / 3),
        lifeBarPaint);
    canvas.drawRect(
        Rect.fromLTWH(left, lifeBarTop, actualWidth, actualHeight / 3),
        lifeBarStrokePaint);
  }
}
