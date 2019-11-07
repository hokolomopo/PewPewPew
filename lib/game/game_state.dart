import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/level.dart';
import 'package:info2051_2018/draw/ui_drawer.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/terrain.dart';
import 'package:info2051_2018/game/ui_manager.dart';
import 'package:info2051_2018/game/utils.dart';
import 'package:info2051_2018/game/world.dart';

/// Enum to describe the current state of the game
enum GameStateMode{char_selection, moving, attacking, cinematic}

class GameState{
  static const List<String> teamNames = ["Red", "Blue", "Green", "Orange"];

  /// Ratio between the size of a drag event and the length of the resulting jump
  static const double JumpVectorNormalizer = 0.1;

  GameStateMode currentState = GameStateMode.char_selection;

  List<List<Character>> players = new List();
  World world = new World();
  LevelPainter painter;
  UiManager uiManager;

  int currentPlayer = 0;
  int currentCharacter = 0;

  /// GameStateMode.moving variables
  bool characterJumping;
  Offset jumpDragStartPosition;
  Offset jumpDragEndPosition;


  GameState(int numberOfPlayers, int numberOfCharacters, this.painter){
    uiManager = UiManager(painter);

    //TODO load level
    this.addTerrainBlock(new TerrainBlock(0, 70, 20000, 10));
    this.addTerrainBlock(new TerrainBlock(150, 0, 10, 20000));

    for(int i = 0;i < numberOfPlayers;i++) {

      List<Character> chars = new List();
      players.add(chars);

      for (int j = 0; j < numberOfCharacters; j++) {

        //TODO how to position characters
        Character c = new Character(new Offset(30 * (j +0.5*i), 10.0), i);
        this.addCharacter(i, c);

        //Make character jump to apply gravity to them
        c.jump(new Offset(0,0));
      }
    }

    switchState(GameStateMode.char_selection);
  }

  void update(){
    world.updateWorld();

    switch(currentState){

      case GameStateMode.char_selection:
        break;
      case GameStateMode.moving:
        if(getCurrentCharacter().stamina == 0 && !getCurrentCharacter().isAirborne())
          switchState(GameStateMode.attacking);
        break;
      case GameStateMode.attacking:
        // TODO: Handle this case.
        switchState(GameStateMode.char_selection);
        break;
      case GameStateMode.cinematic:
        break;
    }
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
        for(int i = 0;i < players[currentPlayer].length;i++)
          if(GameUtils.rectContains(players[currentPlayer][i].hitbox, tapPosition)){
            currentCharacter = i;

            switchState(GameStateMode.moving);
          }
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
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.screenHeight);

    print("PanStart : " + dragPosition.toString() + "char hitbox : " + currentChar.hitbox.toString());

    switch(currentState){

      case GameStateMode.char_selection:
        //TODO move camera
        break;

      case GameStateMode.moving:

        //Drag on character. We extend the size of the hitbox due to imprecision
        //for coordinates in drag events
        if(GameUtils.rectContains(GameUtils.extendRect(currentChar.hitbox, 50), dragPosition)){

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
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.screenHeight);

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
          currentChar.jump((jumpDragStartPosition - jumpDragEndPosition) * JumpVectorNormalizer);
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
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.screenHeight);

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

  /// Function that is called when we change the state of the game
  /// This is used to make sure that all the variables have the correct value at the start
  /// of the state
  void switchState(GameStateMode newState){
    switch(newState){

      case GameStateMode.char_selection:
        this.currentPlayer = (currentPlayer + 1) % players.length;

        uiManager.removeStaminaDrawer();
        uiManager.addTextDrawer(teamNames[currentPlayer] + " team turn !",
            TextPositions.center, 50);
        break;
      case GameStateMode.moving:
        //TODO delete dis
        uiManager.removeTextDrawer();


        this.characterJumping = false;
        this.jumpDragStartPosition = null;
        this.jumpDragEndPosition = null;

        getCurrentCharacter().refillStamina();
        uiManager.addStaminaDrawer(getCurrentCharacter());
        break;
      case GameStateMode.attacking:
        break;
      case GameStateMode.cinematic:
        // TODO: Handle this case.
        break;
    }

    currentState = newState;
  }
}