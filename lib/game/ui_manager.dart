
import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/draw/level.dart';
import 'package:info2051_2018/draw/ui_drawer.dart';
import 'package:info2051_2018/game/character.dart';

class UiManager{
  LevelPainter painter;

  StaminaDrawer staminaDrawer;

  //TODO list & timer
  TextDrawer textDrawer;

  UiManager(this.painter);

  void addStaminaDrawer(Character c){
    staminaDrawer = StaminaDrawer(c);
    painter.addElement(staminaDrawer, index: 100);
  }

  void removeStaminaDrawer(){
    painter.removeElement(staminaDrawer);
  }

  void addTextDrawer(String s, TextPositions position, double fontSize, {Offset customPosition : const Offset(0, 0)}){
    textDrawer = new TextDrawer(s, position, fontSize);
    painter.addElement(textDrawer);
  }

  void removeTextDrawer(){
    painter.removeElement(textDrawer);
  }

}