import 'dart:typed_data';
import 'dart:ui';

import 'paint_constants.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/util/utils.dart';

// TODO Remove and Merge this with Draw Character File

class ProjectileDrawer extends CustomDrawer{
  Uint8List projectileImgBytes;
  Image projectileImg;
  Size screenSize;
  double width;
  double height;

  Projectile projectile;

  ProjectileDrawer(String imgPath, this.projectile,
      {this.width = 5, this.height = 5}) {
    setImg(imgPath);
  }

  setImg(String imgPath) async {
    ByteData bytes = await rootBundle.load(imgPath);
    projectileImgBytes = bytes.buffer.asUint8List();
  }

  _reloadImg(Size screenSize) async {
    Codec codec = await instantiateImageCodec(projectileImgBytes,
        targetWidth:
        (GameUtils.relativeToAbsoluteDist(width, screenSize.height))
            .toInt(),
        targetHeight:
        (GameUtils.relativeToAbsoluteDist(height, screenSize.height))
            .toInt());
    projectileImg = (await codec.getNextFrame()).image;

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
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    double left =
    GameUtils.relativeToAbsoluteDist(projectile.position.dx, size.height);
    double top =
    GameUtils.relativeToAbsoluteDist(projectile.position.dy, size.height);
    double actualWidth = GameUtils.relativeToAbsoluteDist(width, size.height);
    double actualHeight = GameUtils.relativeToAbsoluteDist(height, size.height);

    if (showHitBoxes) {
      canvas.drawRect(Rect.fromLTWH(left, top, actualWidth, actualHeight),
          debugShowHitBoxesPaint);
    }

    canvas.drawImage(projectileImg, Offset(left, top), Paint());

  }

}