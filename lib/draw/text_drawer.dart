import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'level.dart';

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
