import 'package:flutter/material.dart';

import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/draw/text_drawer.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';

class WeaponDrawer extends ImagedDrawer {
  static final double ammunitionRadius = 2.5;
  static final Color outOfAmmoColor = Colors.grey;
  static final Color ammoColor = Colors.white;
  static final Offset ammoTextOffset = Offset(-1.5, -1.5);
  static final double ammoFontSize = 15;

  Weapon weapon;

  WeaponDrawer(AssetId id, this.weapon, Size relativeSize)
      : super(relativeSize, id);

  @override
  void paint(Canvas canvas, Size screenSize, bool showHitBoxes,
      Offset cameraPosition) {
    Character owner = weapon.owner;
    Color teamColor = owner.getTeamColor();
    Offset imgPos;

    // Draw weapon in weapon selection menu
    if (weapon.inSelection) {
      Color circleColor;
      if ((weapon.ammunition ?? 1) > 0) {
        circleColor = teamColor;
      } else {
        circleColor = outOfAmmoColor;
      }

      canvas.drawCircle(
          GameUtils.relativeToAbsoluteOffset(
              weapon.centerPos, screenSize.height),
          GameUtils.relativeToAbsoluteDist(
              Arsenal.selectionElementRadius, screenSize.height),
          Paint()..color = circleColor);

      imgPos = weapon.topLeftPos;
    }

    //Weapon in the hand of the character
    else {
      Offset characterTopLeftPos = Offset(owner.hitbox.left, owner.hitbox.top);
      int dirFaced = weapon.owner.directionFaced;
      imgPos = characterTopLeftPos +
          Weapon.directionFacedToOffset[dirFaced](relativeSize);
    }

    Offset absoluteImgPos =
        GameUtils.relativeToAbsoluteOffset(imgPos, screenSize.height);
    Offset absoluteWeaponShift = GameUtils.relativeToAbsoluteOffset(
        weapon.weaponCenterOffset, screenSize.height);

    if (weapon.owner.directionFaced == Character.RIGHT) {
      //Shift the weapon position to be in the hand of the character
      if (!weapon.inSelection) absoluteImgPos -= absoluteWeaponShift;
      canvas.drawImage(fetchNextFrame(), absoluteImgPos, Paint());
    } else {
      //Shift the weapon position to be in the hand of the character
      if (!weapon.inSelection)
        absoluteImgPos -=
            Offset(-absoluteWeaponShift.dx, absoluteWeaponShift.dy);
      drawFlippedImage(
          canvas,
          fetchNextFrame(),
          Rect.fromLTWH(absoluteImgPos.dx, absoluteImgPos.dy, actualSize.width,
              actualSize.height));
    }

    if (weapon.inSelection && weapon.ammunition != null) {
      Offset ammunitionCenterPos = weapon.centerPos +
          Offset(0, Arsenal.selectionElementRadius - ammunitionRadius);

      canvas.drawCircle(
          GameUtils.relativeToAbsoluteOffset(
              ammunitionCenterPos, screenSize.height),
          GameUtils.relativeToAbsoluteDist(ammunitionRadius, screenSize.height),
          Paint()..color = ammoColor);

      TextDrawer(weapon.ammunition.toString(), TextPositions.custom, ammoFontSize,
          customPosition: ammunitionCenterPos + ammoTextOffset,
          color: Colors.black)
          .paint(canvas, screenSize, showHitBoxes, cameraPosition);
    }
  }
}
