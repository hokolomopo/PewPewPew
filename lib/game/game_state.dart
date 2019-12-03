import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/draw/text_drawer.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/terrain.dart';
import 'package:info2051_2018/game/ui_manager.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/world.dart';

import 'camera.dart';
import 'level.dart';

/// Enum to describe the current state of the game
enum GameStateMode{char_selection, moving, attacking, cinematic}

class GameState{
  static const List<String> teamNames = ["Red", "Blue", "Green", "Orange"];

  /// Ratio between the size of a drag event and the length of the resulting jump
  static const double JumpVectorNormalizer = 2;

  ///Speed of the camera when dragging
  static const double CameraSpeed = 1;

  GameStateMode currentState = GameStateMode.char_selection;

  List<List<Character>> players = new List();
  World world = new World();
  LevelPainter painter;
  UiManager uiManager;
  Level level;
  Camera camera;

  int currentPlayer = 0;
  int currentCharacter = 0;

  ///GameStateMode.char_selection variables
  TextFader teamTurnText;
  Offset cameraDragStartLocation;

  /// GameStateMode.moving variables
  bool characterJumping;
  Offset jumpDragStartPosition;
  Offset jumpDragEndPosition;
  Offset moveDestination;


  GameState(int numberOfPlayers, int numberOfCharacters, this.painter, this.level, this.camera){
    uiManager = UiManager(painter);

    level.spawnPoints.shuffle();

    for(TerrainBlock block in level.terrain)
      this.addTerrainBlock(block);

    for(int i = 0;i < numberOfPlayers;i++) {

      List<Character> chars = List();
      players.add(chars);

      for (int j = 0; j < numberOfCharacters; j++) {
        Character c = Character(level.spawnPoints[i * numberOfCharacters + j], i);
        this.addCharacter(i, c);

        //Make character jump to apply gravity to them
        c.jump(Offset(0,0));
      }
    }

    switchState(GameStateMode.char_selection);
  }

  void update(double timeElapsed){
    world.updateWorld(timeElapsed);
    uiManager.updateUi(timeElapsed);

    Character currentChar = getCurrentCharacter();

    switch(currentState){

      case GameStateMode.char_selection:
        break;
      case GameStateMode.moving:

        //Check if we need to remove the marker because the character has jumped
        if(currentChar.isAirborne() && moveDestination != null){
          uiManager.removeMarker();
          moveDestination = null;
        }

        //Check if the destination of a displacement has been reached
        if(moveDestination != null && !currentChar.isAirborne()){

          //We stop only if the destination is within the centric third of the hitbox
          if(moveDestination.dx >= currentChar.hitbox.left + currentChar.hitbox.width / 3 &&
              moveDestination.dx <= currentChar.hitbox.left + currentChar.hitbox.width * 2 / 3){
            currentChar.stop();
            uiManager.removeMarker();
            moveDestination = null;
          }
        }

        //Stop the phase if the character has no stamina left
        if(currentChar.stamina == 0 && !currentChar.isAirborne()) {
          switchState(GameStateMode.attacking);
        }

        //Center the camera on the character
        this.camera.centerOn(getCurrentCharacter().position);

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
    Offset tapPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.size.height);

    //Take camera into account
    Offset tapPositionCamera = tapPosition + camera.position;

    print("OnTap : " + tapPosition.toString() + "char hitbox : " + getCurrentCharacter().hitbox.toString());

    switch(currentState){
      case GameStateMode.char_selection:
        for(int i = 0;i < players[currentPlayer].length;i++)
          if(GameUtils.rectContains(players[currentPlayer][i].hitbox, tapPositionCamera)){
            currentCharacter = i;

            switchState(GameStateMode.moving);
          }
        break;

      case GameStateMode.moving:
        Character currentChar = getCurrentCharacter();

        //Touch event on the current character
        if(GameUtils.rectContains(currentChar.hitbox, tapPositionCamera)){
          if(!currentChar.isAirborne()) {
            currentChar.stopX();
            moveDestination = null;
            uiManager.removeMarker();
          }
        }

        //Touch event left of the current character
        else if(GameUtils.rectLeftOf(currentChar.hitbox, tapPositionCamera)){
          if(!currentChar.isAirborne()) {
            currentChar.beginWalking(Character.LEFT);
            this.startMoving(tapPositionCamera);
          }
        }

        //Touch event right of the current character
        else if(GameUtils.rectRightOf(currentChar.hitbox, tapPositionCamera)){
          if(!currentChar.isAirborne()) {
            currentChar.beginWalking(Character.RIGHT);
            this.startMoving(tapPositionCamera);
          }
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
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.size.height);
    Offset dragPositionCamera = dragPosition + camera.position;

    print("PanStart : " + dragPosition.toString() + "char hitbox : " + currentChar.hitbox.toString());

    switch(currentState){

      case GameStateMode.char_selection:
        this.cameraDragStartLocation = dragPosition;
        break;

      case GameStateMode.moving:

        //Drag on character. We extend the size of the hitbox due to imprecision
        //for coordinates in drag events
        if(GameUtils.rectContains(GameUtils.extendRect(currentChar.hitbox, 50), dragPositionCamera)){

          if(currentChar.isAirborne())
            return;
          currentChar.stop();

          characterJumping = true;
          jumpDragStartPosition = dragPositionCamera;
          
          uiManager.beginJump(GameUtils.getRectangleCenter(currentChar.hitbox));
        }
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        break;

      case GameStateMode.cinematic:
        break;
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.size.height);
    Offset dragPositionCamera = dragPosition + camera.position;

    switch (currentState) {
      case GameStateMode.char_selection:
        camera.position += (this.cameraDragStartLocation - dragPosition) * CameraSpeed;
        this.cameraDragStartLocation = dragPosition;
        break;

      case GameStateMode.moving:
        if (characterJumping) {
          jumpDragEndPosition = dragPositionCamera;
          uiManager.updateJump(Character.getJumpSpeed((dragPositionCamera - jumpDragStartPosition ) * JumpVectorNormalizer));
        }
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
          uiManager.endJump();
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
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(details.globalPosition, GameMain.size.height);

    switch(currentState){

      case GameStateMode.char_selection:
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

  /// Function used when starting the movement of a character. It place a marker
  /// on top of the terrain the closest to the destination
  void startMoving(Offset destination){
    Offset markerPosition = destination;

    TerrainBlock closest = world.getClosestTerrainUnder(destination);
    if(closest != null && camera.isDisplayed(closest.hitBox))
      markerPosition = Offset(destination.dx, closest.hitBox.top);


    this.moveDestination = markerPosition;
    this.uiManager.addMarker(markerPosition);
  }

  /// Function that is called when we change the state of the game
  /// This is used to make sure that all the variables have the correct value at the start
  /// and end of the state
  void switchState(GameStateMode newState){
    this.endState(currentState);
    this.startState(newState);

    currentState = newState;
  }

  void startState(GameStateMode newState){
    switch(newState){

      case GameStateMode.char_selection:
        this.currentPlayer = (currentPlayer + 1) % players.length;

        uiManager.removeStaminaDrawer();
        this.teamTurnText = uiManager.addText(teamNames[currentPlayer] + " team turn !",
            TextPositions.center, 50, duration: 3, fadeDuration: 3, ignoreCamera: true);
        break;
      case GameStateMode.moving:
        this.characterJumping = false;
        this.jumpDragStartPosition = null;
        this.jumpDragEndPosition = null;

        getCurrentCharacter().refillStamina();
        uiManager.addStaminaDrawer(getCurrentCharacter());
        break;
      case GameStateMode.attacking:
        break;
      case GameStateMode.cinematic:
        break;
    }
  }

  void endState(GameStateMode oldState){
    switch(oldState){

      case GameStateMode.char_selection:
        uiManager.removeText(this.teamTurnText);
        break;
      case GameStateMode.moving:
        uiManager.removeMarker();
        getCurrentCharacter().stop();
        break;
      case GameStateMode.attacking:
        break;
      case GameStateMode.cinematic:
        break;
    }
  }
}