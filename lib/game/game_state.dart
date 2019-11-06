import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/level.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/terrain.dart';
import 'package:info2051_2018/game/utils.dart';
import 'package:info2051_2018/game/world.dart';

enum GameStateMode{char_selection, moving, attacking, cinematic}

class GameState{
  GameStateMode currentState = GameStateMode.moving;

  List<List<Character>> players = new List();
  World world = new World();
  LevelPainter painter;

  int currentPlayer = 0;
  int currentCharacter = 0;

  //Moving state variables
  bool characterJumping = false;
  Offset jumpDragStartPosition;
  Offset jumpDragEndPosition;


  GameState(int numberOfPlayers, int numberOfCharacters, this.painter){
    //TODO load level
    this.addTerrainBlock(new TerrainBlock(0, 70, 20000, 10));
    this.addTerrainBlock(new TerrainBlock(150, 0, 10, 20000));

    for(int i = 0;i < numberOfPlayers;i++) {

      List<Character> chars = new List();
      players.add(chars);

      for (int j = 0; j < numberOfCharacters; j++) {

        //TODO how to position characters
        Character c = new Character(new Offset(10.0, 10.0));
        this.addCharacter(i, c);

        //TODO delete dis
        c.jump(new Offset(0,0));
      }
    }
  }

  void update(){
    world.updateWorld();
  }

  void addCharacter(int playerId, Character character){
    players[playerId].add(character);

    world.addCharacter(character);
    painter.addElement(character.drawer);
  }

  void removeCharacter(int playerId, Character character){
    players[playerId].remove(character);

    world.removeCharacter(character);
    painter.removeElement(character.drawer);
  }

  void addTerrainBlock(TerrainBlock block){
    world.addTerrain(block);
    painter.addElement(block.drawer);
  }
  
  void removeTerrainBlock(TerrainBlock block){
    world.removeTerrain(block);
    painter.addElement(block.drawer);
  }

  Character getCurrentCharacter(){
    return players[currentPlayer][currentCharacter];
  }

  void onTap(TapDownDetails details){
    Offset tapPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.screenHeight);

    print("OnTap : " + tapPosition.toString() + "char hitbox : " + getCurrentCharacter().hitbox.toString());

    switch(currentState){
      case GameStateMode.char_selection:
        // TODO: Handle this case.
        break;

      case GameStateMode.moving:
        Character currentChar = getCurrentCharacter();

        //Touch event on the current character
        if(GameUtils.rectContains(currentChar.hitbox, tapPosition)){
          if(!currentChar.isAirborne())
            currentChar.stopX();
        }

        //Touch event left of the current character
        else if(GameUtils.rectLeftOf(currentChar.hitbox, tapPosition)){
          currentChar.beginWalking(Character.LEFT);
        }

        //Touch event right of the current character
        else if(GameUtils.rectRightOf(currentChar.hitbox, tapPosition)){
          currentChar.beginWalking(Character.RIGHT);
        }
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        break;

      case GameStateMode.cinematic:
        break;
    }

  }

  void onPanStart(DragStartDetails details){
    Character currentChar = getCurrentCharacter();
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.screenHeight);;

    print("PanStart : " + dragPosition.toString() + "char hitbox : " + currentChar.hitbox.toString());

    switch(currentState){

      case GameStateMode.char_selection:
        //TODO move camera
        break;

      case GameStateMode.moving:

        //Drag on character. We extend the size of the hitbox due to imprecision
        //for coordinates in drag events
        if(GameUtils.rectContains(GameUtils.extendRect(currentChar.hitbox, 50), dragPosition)){
          print("PAnOnChar");

          if(currentChar.isAirborne())
            return;
          currentChar.stop();

          characterJumping = true;
          jumpDragStartPosition = dragPosition;
        }

        //TODO drag move camera
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        break;

      case GameStateMode.cinematic:
        break;
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.screenHeight);;

    switch (currentState) {
      case GameStateMode.char_selection:
      //TODO Move camera.
        break;

      case GameStateMode.moving:
        if (characterJumping) {
          // TODO: Draw directional arrow
          jumpDragEndPosition = dragPosition;
        }

        //TODO : Move camera
        break;

      case GameStateMode.attacking:
      // TODO: Handle this case.
        break;

      case GameStateMode.cinematic:
        break;
    }
  }

  void onPanEnd(DragEndDetails details){
    Character currentChar = getCurrentCharacter();

    switch(currentState){
      case GameStateMode.char_selection:
        break;

      case GameStateMode.moving:
        if(characterJumping){
          currentChar.jump(jumpDragStartPosition - jumpDragEndPosition);
          characterJumping = false;
        }
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        break;

      case GameStateMode.cinematic:
        break;
    }
  }

  void onLongPress(LongPressStartDetails details){
    Character currentChar = getCurrentCharacter();
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.screenHeight);;

    switch(currentState){

      case GameStateMode.char_selection:
        // TODO: select character.
        break;

      case GameStateMode.moving:
        if(GameUtils.rectContains(currentChar.hitbox, dragPosition)){
          if(currentChar.isAirborne())
            return;
          currentChar.stop();

          //TODO : display armory
          print("Armory is here");
        }

        break;

      case GameStateMode.attacking:
        break;
      case GameStateMode.cinematic:
        break;
    }
  }
}