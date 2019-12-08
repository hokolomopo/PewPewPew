import 'package:flutter/material.dart';

import 'paint_constants.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'level_painter.dart';

class CharacterDrawer extends CustomDrawer {
  Character character;

  CharacterDrawer(String gifPath, this.character,
      {Size screenSize, Size size = const Size(10, 10)})
      : super(size, gifPath, screenSize: screenSize);

  @override
  bool isReady2(Size screenSize) {
    super.isReady2(screenSize);
    return imgAndGif.containsKey(gifPath) &&
        imgAndGif[gifPath].containsKey(relativeSize) &&
        imgAndGif[gifPath][relativeSize] != null &&
        imgAndGif[gifPath][relativeSize].fetchNextFrame() != null;
  }

  @override
  void paint(
      Canvas canvas, Size screenSize, showHitBoxes, Offset cameraPosition) {
    double left = GameUtils.relativeToAbsoluteDist(
        character.position.dx, screenSize.height);
    double top = GameUtils.relativeToAbsoluteDist(
        character.position.dy, screenSize.height);

    if (showHitBoxes) {
      canvas.drawRect(
          Rect.fromLTWH(left, top, actualSize.width, actualSize.height),
          debugShowHitBoxesPaint);
    }

    canvas.drawImage(fetchNextFrame2(), Offset(left, top), Paint());

    double lifeBarTop = top - distanceLifeBarCharacter * screenSize.height;
    Color lifeColor = character.getTeamColor();
    double normalizedHp = character.hp / Character.base_hp;
    Paint lifeBarPaint = Paint()
      ..color = lifeColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(left, lifeBarTop, actualSize.width * normalizedHp,
            actualSize.height / 3),
        lifeBarPaint);
    canvas.drawRect(
        Rect.fromLTWH(
            left, lifeBarTop, actualSize.width, actualSize.height / 3),
        lifeBarStrokePaint);
  }
}
