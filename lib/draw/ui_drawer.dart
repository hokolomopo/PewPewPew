import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/paint_constants.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/util/utils.dart';

import 'assets_manager.dart';
import 'drawer_abstracts.dart';

class StaminaDrawer extends CustomDrawer {
  static const Size actionBarSize = Size(30, 8);
  static const double distFromBottom = 3;

  Character character;

  StaminaDrawer(this.character) : super(null);

  @override
  void paint(Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    double width = GameUtils.relativeToAbsoluteDist(actionBarSize.width, size.height);
    double height = GameUtils.relativeToAbsoluteDist(actionBarSize.height, size.height);
    double left = size.width / 2 - width / 2;
    double top = size.height - height -
        GameUtils.relativeToAbsoluteDist(distFromBottom, size.height);

    Offset position = this.cancelCamera(Offset(left, top), cameraPosition);

    double staminaRatio = character.stamina / Character.baseStamina;

    canvas.drawRect(Rect.fromLTWH(position.dx, position.dy, width * staminaRatio, height), actionBarFillPaint);
    canvas.drawRect(Rect.fromLTWH(position.dx, position.dy, width, height), actionBarStrokePaint);
  }

}

class MarkerDrawer extends ImagedDrawer{
  static const Size markerArrowSize = Size(6, 6);

  Offset position;

  MarkerDrawer(this.position) : super(markerArrowSize, AssetId.ui_arrow);

  @override
  void paint(Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    double x = GameUtils.relativeToAbsoluteDist(position.dx, size.height);
    double y = GameUtils.relativeToAbsoluteDist(position.dy, size.height);
    double width = GameUtils.relativeToAbsoluteDist(markerArrowSize.width, size.height);
    double height = GameUtils.relativeToAbsoluteDist(markerArrowSize.height, size.height);

    canvas.drawImage(fetchNextFrame(), Offset(x - width / 2, y - height), Paint());
  }

}

class JumpArrowDrawer extends CustomDrawer{
  double normalizingFactor;

  Offset origin;
  Offset end;

  JumpArrowDrawer(this.origin, this.end, {this.normalizingFactor:0.5}) : super(null);

  @override
  void paint(Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    Offset originAbs = GameUtils.relativeToAbsoluteOffset(origin, size.height);
    Offset endAbs = GameUtils.relativeToAbsoluteOffset(end, size.height);

    Offset direction = endAbs - originAbs;
    direction = direction * normalizingFactor;

    endAbs = originAbs + direction;

    canvas.drawLine(originAbs, endAbs, jumpLinePaint);

  }

}

class LoadingScreenDrawer extends CustomDrawer{
  LoadingScreenDrawer() : super(null);

  @override
  void paint(Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    ParagraphBuilder textBuilder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.left, fontSize: 50.0))
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText('loading...');
    Paragraph text = textBuilder.build()
      ..layout(ParagraphConstraints(
          width: (size.width < 250) ? size.width : 250));

    canvas.drawParagraph(
        text,
        Offset((size.width - text.width) / 2,
            (size.height - text.height) / 2));
  }
}