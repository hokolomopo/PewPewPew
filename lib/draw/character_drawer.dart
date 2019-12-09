import 'package:flutter/material.dart';

import 'assets_manager.dart';
import 'drawer_abstracts.dart';
import 'paint_constants.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';

class CharacterDrawer extends ImagedDrawer {
  Character character;

  CharacterDrawer(AssetId id, this.character,
      {Size size = const Size(10, 10)})
      : super(size, id);

  @override
  void paint(
      Canvas canvas, Size screenSize, showHitBoxes, Offset cameraPosition) {
    double left = GameUtils.relativeToAbsoluteDist(
        character.getSpritePosition().dx, screenSize.height);
    double top = GameUtils.relativeToAbsoluteDist(
        character.getSpritePosition().dy, screenSize.height);

    if (showHitBoxes) {
      canvas.drawRect(
          Rect.fromLTWH(
              GameUtils.relativeToAbsoluteDist(
                  character.hitbox.left, screenSize.height),
              GameUtils.relativeToAbsoluteDist(
                  character.hitbox.top, screenSize.height),
              GameUtils.relativeToAbsoluteDist(
                  character.hitbox.width, screenSize.height),
              GameUtils.relativeToAbsoluteDist(
                  character.hitbox.height, screenSize.height)),
              debugShowHitBoxesPaint);
    }

    canvas.drawImage(fetchNextFrame(), Offset(left, top), Paint());

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
