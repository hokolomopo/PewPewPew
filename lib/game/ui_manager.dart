import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/game/draw/level_painter.dart';
import 'package:info2051_2018/game/draw/text_drawer.dart';
import 'package:info2051_2018/game/draw/ui_drawer.dart';
import 'package:info2051_2018/game/character.dart';

class UiManager {
  LevelPainter painter;

  List<TextFader> textFaders = new List();

  StaminaDrawer staminaDrawer;
  MarkerDrawer marker;
  JumpArrowDrawer jumpArrowDrawer;

  UiManager(this.painter);

  void updateUi(double elapsedTime) {
    for (int i = 0; i < textFaders.length; i++) {
      if (textFaders[i].isDead) {
        removeText(textFaders[i]);
        i--;
        continue;
      }
      textFaders[i].update(elapsedTime);
    }
  }

  void addStaminaDrawer(Character c) {
    staminaDrawer = StaminaDrawer(c);
    painter.addElement(staminaDrawer, index: 100);
  }

  void removeStaminaDrawer() {
    painter.removeElement(staminaDrawer);
    staminaDrawer = null;
  }

  TextFader addText(String s, TextPositions position, double fontSize,
      {Offset customPosition: const Offset(0, 0),
      double duration,
      double fadeDuration = 0,
      bool ignoreCamera: false,
      Color color: Colors.white}) {
    TextDrawer textDrawer = TextDrawer(s, position, fontSize,
        customPosition: customPosition,
        ignoreCamera: ignoreCamera,
        color: color);

    painter.addElement(textDrawer);

    TextFader fader =
        TextFader(textDrawer, lifetime: duration, fadeTime: fadeDuration);
    textFaders.add(fader);

    return fader;
  }

  void removeText(TextFader fader) {
    if (fader == null) return;
    painter.removeElement(fader.drawer);
    textFaders.remove(fader);
  }

  void addMarker(Offset position) {
    if (this.marker != null) removeMarker();
    this.marker = MarkerDrawer(position);
    painter.addElement(marker);
  }

  void removeMarker() {
    painter.removeElement(marker);
    this.marker = null;
  }

  void beginJump(Offset origin, {double normalizingFactor:0.5}) {
    jumpArrowDrawer = JumpArrowDrawer(origin, origin);
    painter.addElement(jumpArrowDrawer);
  }

  void updateJump(Offset offset) {
    jumpArrowDrawer.end = jumpArrowDrawer.origin - offset;
  }

  void endJump() {
    painter.removeElement(jumpArrowDrawer);
    jumpArrowDrawer = null;
  }
}

class TextFader {
  double lifetime;
  double fadeTime;
  double elapsedTime = 0;

  TextDrawer drawer;

  bool isDead = false;

  ///  Arguments :
  ///  drawer   : The TextDrawer to draw
  ///  lifetime : Duration when the text is not fading (in seconds). Null is infinite.
  ///  fadeTime : Duration of the fading of the text (in seconds)
  TextFader(this.drawer, {this.lifetime, this.fadeTime: 0});

  void update(double elapsed) {
    if (lifetime == null) return;

    this.elapsedTime += elapsed;

    if (elapsedTime < lifetime)
      return;
    else if (elapsedTime < lifetime + fadeTime)
      drawer.opacity = 1 - ((elapsedTime - lifetime) / fadeTime);
    else
      isDead = true;
  }
}
