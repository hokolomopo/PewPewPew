import 'package:flutter/material.dart';

import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';

class WeaponDrawer extends ImagedDrawer {
  Weapon weapon;

  WeaponDrawer(AssetId id, this.weapon, Size relativeSize)
      : super(relativeSize, id);

  @override
  void paint(Canvas canvas, Size screenSize, bool showHitBoxes,
      Offset cameraPosition) {
    Character owner = weapon.owner;
    Color teamColor = owner.getTeamColor();
    Offset imgPos;

    if (weapon.inSelection) {
      canvas.drawCircle(
          GameUtils.relativeToAbsoluteOffset(
              weapon.centerPos, screenSize.height),
          GameUtils.relativeToAbsoluteDist(
              Arsenal.selectionElementRadius, screenSize.height),
          Paint()..color = teamColor);

      imgPos = weapon.topLeftPos;
    } else {
      Offset characterTopLeftPos = Offset(owner.hitbox.left, owner.hitbox.top);
      int dirFaced = weapon.owner.directionFaced;
      imgPos = characterTopLeftPos +
          Weapon.directionFacedToOffset[dirFaced](relativeSize);
    }

    Offset absoluteImgPos =
        GameUtils.relativeToAbsoluteOffset(imgPos, screenSize.height);

    if (weapon.owner.directionFaced == Character.RIGHT) {
      canvas.drawImage(fetchNextFrame(), absoluteImgPos, Paint());
    } else {
      drawFlippedImage(
          canvas,
          fetchNextFrame(),
          Rect.fromLTWH(absoluteImgPos.dx, absoluteImgPos.dy, actualSize.width,
              actualSize.height));
    }
  }
}
