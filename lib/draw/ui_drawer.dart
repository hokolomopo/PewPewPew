import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/paint_constants.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/utils.dart';

import 'level.dart';

class StaminaDrawer extends CustomDrawer {
  static const double actionBarWidth = 30;
  static const double actionBarHeight = 8;
  static const double distFromBottom = 3;

  Character character;

  StaminaDrawer(this.character);

  @override
  void paint(Canvas canvas, Size size, bool showHitBoxes) {
    double width = GameUtils.relativeToAbsoluteDist(actionBarWidth, size.height);
    double height = GameUtils.relativeToAbsoluteDist(actionBarHeight, size.height);
    double left = size.width / 2 - width / 2;
    double top = size.height - height -
        GameUtils.relativeToAbsoluteDist(distFromBottom, size.height);

    double staminaRatio = character.stamina / Character.baseStamina;

    canvas.drawRect(Rect.fromLTWH(left, top, width * staminaRatio, height), actionBarFillPaint);
    canvas.drawRect(Rect.fromLTWH(left, top, width, height), actionBarStrokePaint);
  }

}

class MarkerDrawer extends CustomDrawer{

  Offset position;

  MarkerDrawer(this.position);

  @override
  void paint(Canvas canvas, Size size, bool showHitBoxes) {
    double x = GameUtils.relativeToAbsoluteDist(position.dx, size.height);
    double y = GameUtils.relativeToAbsoluteDist(position.dy, size.height);

    double width = 10;
    double height = 10;

    //TODO draw arrow instead of random rectangle
    canvas.drawRect(Rect.fromLTWH(x - width /2, y - height, 10, 10), blackPaint);
  }

}