
import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/draw/level.dart';
import 'package:info2051_2018/draw/text_drawer.dart';
import 'package:info2051_2018/draw/ui_drawer.dart';
import 'package:info2051_2018/game/character.dart';

class UiManager{
  LevelPainter painter;

  StaminaDrawer staminaDrawer;

  List<TextFader> textFaders = new List();

  UiManager(this.painter);

  MarkerDrawer marker;

  void updateUi(double elapsedTime){
    for(int i = 0;i < textFaders.length;i++){
      if(textFaders[i].isDead){
        removeText(textFaders[i]);
        i--;
        continue;
      }
      textFaders[i].update(elapsedTime);
    }
  }

  void addStaminaDrawer(Character c){
    staminaDrawer = StaminaDrawer(c);
    painter.addElement(staminaDrawer, index: 100);
  }

  void removeStaminaDrawer(){
    painter.removeElement(staminaDrawer);
    staminaDrawer = null;
  }

  TextFader addText(String s, TextPositions position, double fontSize,
      {Offset customPosition : const Offset(0, 0),
        double duration,
        double fadeDuration = 0}){
    TextDrawer textDrawer = new TextDrawer(s, position, fontSize);
    painter.addElement(textDrawer);

    TextFader fader = TextFader(textDrawer, lifetime: duration, fadeTime: fadeDuration);
    textFaders.add(fader);

    return fader;
  }

  void removeText(TextFader fader){
    if(fader == null)
      return;
    painter.removeElement(fader.drawer);
    textFaders.remove(fader);
  }

  void addMarker(Offset position){
    if(this.marker != null)
      removeMarker();
    this.marker = MarkerDrawer(position);
    painter.addElement(marker);
  }

  void removeMarker(){
    painter.removeElement(marker);
    this.marker = null;
  }

}

class TextFader{
  double lifetime;
  double fadeTime;
  double elapsedTime = 0;

  TextDrawer drawer;

  bool isDead = false;

  ///  Arguments :
  ///  drawer   : The TextDrawer to draw
  ///  lifetime : Duration when the text is not fading (in seconds). Null is infinite.
  ///  fadeTime : Duration of the fading of the text (in seconds)
  TextFader(this.drawer,{this.lifetime, this.fadeTime : 0});

  void update(double elapsed){
    if(lifetime == null)
      return;

    this.elapsedTime += elapsed;

    if(elapsedTime < lifetime)
      return;

    else if(elapsedTime < lifetime + fadeTime)
      drawer.opacity = 1 - ((elapsedTime - lifetime) / fadeTime);

    else
      isDead = true;

  }
}
