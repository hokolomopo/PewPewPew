import 'dart:ui' as ui;

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
    int dirFaced = weapon.owner.directionFaced;

    angle ??= 0;

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

      imgPos = GameUtils.relativeToAbsoluteOffset(weapon.topLeftPos, screenSize.height);
      drawImage(canvas, fetchNextFrame(), imgPos, flipped: dirFaced == Character.LEFT);
      if (weapon.ammunition != double.infinity) {
        Offset ammunitionCenterPos = weapon.centerPos +
            Offset(0, Arsenal.selectionElementRadius - ammunitionRadius);

        canvas.drawCircle(
            GameUtils.relativeToAbsoluteOffset(
                ammunitionCenterPos, screenSize.height),
            GameUtils.relativeToAbsoluteDist(ammunitionRadius, screenSize.height),
            Paint()..color = ammoColor);

        TextDrawer(weapon.ammunition.toInt().toString(), TextPositions.custom,
            ammoFontSize,
            customPosition: ammunitionCenterPos + ammoTextOffset,
            color: Colors.black)
            .paint(canvas, screenSize, showHitBoxes, cameraPosition);
      }
    } else {
      Offset characterTopLeftPos = Offset(owner.hitbox.left, owner.hitbox.top);
      imgPos = GameUtils.relativeToAbsoluteOffset(characterTopLeftPos +
          weapon.directionFacedToOffset[dirFaced](relativeSize), screenSize.height);
      Offset playerCenter = Offset(
          weapon.owner.getSpritePosition().dx + Character.spriteSize.width / 2,
          weapon.owner.getSpritePosition().dy + Character.spriteSize.height / 2);

      drawImage(canvas, fetchNextFrame(), imgPos,
          rotationCenter: GameUtils.relativeToAbsoluteOffset(
              playerCenter, screenSize.height),
          angle: angle,
          flipped: dirFaced == Character.LEFT,
          target: GameUtils.relativeToAbsoluteSize(weapon.relativeSize, screenSize.height));
    }
  }
}
