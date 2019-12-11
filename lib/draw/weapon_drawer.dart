

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

    if(angle == null)
      angle = 0;

    // Draw weapon in weapon selection menu
    if (weapon.inSelection) {
      Color circleColor;
      if (weapon.ammunition > 0) {
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
    Offset absoluteWeaponShift =
        GameUtils.relativeToAbsoluteOffset(weapon.weaponCenterOffset, screenSize.height);
    Offset playerCenter = Offset(weapon.owner.getSpritePosition().dx + Character.spriteSize.width /2,
        weapon.owner.getSpritePosition().dy + Character.spriteSize.height /2);

    if (weapon.owner.directionFaced == Character.RIGHT) {
      //Shift the weapon position to be in the hand of the character
      if(!weapon.inSelection) {
        drawRotatedImage(fetchNextFrame(), canvas,
            GameUtils.relativeToAbsoluteOffset(playerCenter, screenSize.height), absoluteImgPos, angle, offset: absoluteWeaponShift*-1);
      }
      else
        canvas.drawImage(fetchNextFrame(), absoluteImgPos, Paint());

    } else {
      //Shift the weapon position to be in the hand of the character
      if(!weapon.inSelection) {
        drawRotatedImage(fetchNextFrame(), canvas,
            GameUtils.relativeToAbsoluteOffset(playerCenter, screenSize.height), absoluteImgPos, angle, offset: absoluteWeaponShift*-1, flipped:true);
      }
      else
        drawFlippedImage(
            canvas,
            fetchNextFrame(),
            Rect.fromLTWH(absoluteImgPos.dx, absoluteImgPos.dy, actualSize.width,
                actualSize.height));
    }

    if (weapon.inSelection && weapon.ammunition != double.infinity) {
      Offset ammunitionCenterPos = weapon.centerPos +
          Offset(0, Arsenal.selectionElementRadius - ammunitionRadius);

      canvas.drawCircle(
          GameUtils.relativeToAbsoluteOffset(
              ammunitionCenterPos, screenSize.height),
          GameUtils.relativeToAbsoluteDist(ammunitionRadius, screenSize.height),
          Paint()..color = ammoColor);

      TextDrawer(weapon.ammunition.toInt().toString(), TextPositions.custom, ammoFontSize,
          customPosition: ammunitionCenterPos + ammoTextOffset,
          color: Colors.black)
          .paint(canvas, screenSize, showHitBoxes, cameraPosition);
    }
  }
}
