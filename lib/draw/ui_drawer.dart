import 'dart:ui';
import 'dart:ui' as ui;

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

enum TextPositions{center, custom}

class TextDrawer extends CustomDrawer {
  String content;
  double fontSize;
  TextPositions position;
  Offset customPosition;
  Color color;

  double opacity;

  TextDrawer(this.content, this.position, this.fontSize,
      {this.customPosition : const Offset(0,0),
       this.color : Colors.white,
       this.opacity: 1});

  @override
  void paint(Canvas canvas, Size size, bool showHitBoxes) {
    ParagraphBuilder textBuilder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.center, fontSize: fontSize))
      ..pushStyle(ui.TextStyle(color: this.color.withOpacity(opacity)))
      ..addText(content);
    Paragraph text = textBuilder.build()
      ..layout(ParagraphConstraints(width: size.width));

    canvas.drawParagraph(text, getPosition(size, text));
  }

  Offset getPosition(Size size, Paragraph text){
    switch(position){
      case TextPositions.center:
        return Offset((size.width - text.width) / 2,
            (size.height - text.height) / 2);
      case TextPositions.custom:
        return this.customPosition;
    }

    return this.customPosition;
  }
}
