import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:info2051_2018/game/util/utils.dart';

import 'drawer_abstracts.dart';

enum TextPositions { center, custom }

class TextDrawer extends CustomDrawer {
  String content;
  double fontSize;
  TextPositions position;
  Offset customPosition;
  Color color;
  bool ignoreCamera;

  double opacity;

  TextDrawer(this.content, this.position, this.fontSize,
      {this.customPosition: const Offset(0, 0),
      this.color: Colors.white,
      this.opacity: 1,
      this.ignoreCamera = false})
      : super(null);

  @override
  void paint(
      Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    TextAlign align;
    if (position == TextPositions.custom) {
      align = TextAlign.left;
    } else {
      align = TextAlign.center;
    }
    ParagraphBuilder textBuilder =
        ParagraphBuilder(ParagraphStyle(textAlign: align, fontSize: fontSize))
          ..pushStyle(ui.TextStyle(color: this.color.withOpacity(opacity)))
          ..addText(content);
    Paragraph text = textBuilder.build()
      ..layout(ParagraphConstraints(width: size.width));

    canvas.drawParagraph(text, getPosition(size, text, cameraPosition));
  }

  Offset getPosition(Size size, Paragraph text, Offset cameraPosition) {
    Offset ret;

    switch (position) {
      case TextPositions.center:
        ret = Offset(0.0, (size.height - text.height) / 2);
        break;
      case TextPositions.custom:
        ret = GameUtils.relativeToAbsoluteOffset(
            this.customPosition, size.height);
        break;
    }

    if (ignoreCamera) ret = this.cancelCamera(ret, cameraPosition);

    return ret;
  }
}
