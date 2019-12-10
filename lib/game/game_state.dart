import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/draw/text_drawer.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/terrain.dart';
import 'package:info2051_2018/game/ui_manager.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/world.dart';
import 'package:info2051_2018/sound_player.dart';

import 'camera.dart';
import 'level.dart';

/// Enum to describe the current state of the game
enum GameStateMode {
  char_selection,
  moving,
  attacking,
  projectile,
  cinematic,
  over
}

class GameState {
  static const List<String> teamNames = ["Red", "Blue", "Green", "Orange"];

  /// Ratio between the size of a drag event and the length of the resulting jump
  static const double JumpVectorNormalizer = 2;

  /// Ratio between the size of a drag event and the length of the resulting jump
  static const double LaunchVectorNormalizer = 5;

  ///Speed of the camera when dragging
  static const double CameraSpeed = 1;

  GameStateMode currentState = GameStateMode.char_selection;

  List<List<Character>> players = new List();
  World world = new World();
  LevelPainter painter;
  UiManager uiManager;
  Level level;
  Camera camera;
  SoundPlayer soundPlayer = new SoundPlayer(true);

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

  bool currentCharIsDead = false;

  /// GameStateMode.attacking variables
  bool ammoLaunching;
  Offset launchDragStartPosition;
  Offset launchDragEndPosition;
  Weapon currentWeapon;

  /// GameStateMode.projectile variables
  Stopwatch stopWatch = Stopwatch();

  GameState(int numberOfPlayers, int numberOfCharacters, this.painter,
      this.level, this.camera) {
    uiManager = UiManager(painter);

    level.spawnPoints.shuffle();

    for (TerrainBlock block in level.terrain) this.addTerrainBlock(block);

    for (int i = 0; i < numberOfPlayers; i++) {
      List<Character> chars = List();
      players.add(chars);

      for (int j = 0; j < numberOfCharacters; j++) {
        Character c =
            Character(level.spawnPoints[i * numberOfCharacters + j], i);
        this.addCharacter(i, c);

        //Make character jump to apply gravity to them
        c.jump(Offset(0, 0));
      }
    }

    switchState(GameStateMode.char_selection);
  }

  void update(double timeElapsed) {
    world.updateWorld(timeElapsed);
    uiManager.updateUi(timeElapsed);

    //TODO delete dis
    for(var v in players)
      for(Character c in v)
        c.removeHp(0.06, null);


    bool shouldEndTurn = false;

    switch (currentState) {
      case GameStateMode.char_selection:
        break;
      case GameStateMode.moving:
        Character currentChar = getCurrentCharacter();

        //Check if we need to remove the marker because the character has jumped
        if (currentChar.isAirborne() && moveDestination != null) {
          uiManager.removeMarker();
          moveDestination = null;
        }

        //Check if the destination of a displacement has been reached
        if (moveDestination != null && !currentChar.isAirborne()) {
          //We stop only if the destination is within the central third of the hitbox
          //or if the character has stopped
          if ((moveDestination.dx >=
                  currentChar.hitbox.left + currentChar.hitbox.width / 3 &&
              moveDestination.dx <=
                  currentChar.hitbox.left + currentChar.hitbox.width * 2 / 3) ||
                !currentChar.isMoving()) {
            currentChar.stop();
            uiManager.removeMarker();
            moveDestination = null;
          }
        }

        //Center the camera on the character
        this.camera.centerOn(getCurrentCharacter().getPosition());

        //Stop the phase if the character has no stamina left
        if (currentChar.stamina == 0 && !currentChar.isAirborne()) {
          switchState(GameStateMode.attacking);
        }


        break;
      case GameStateMode.attacking:
        // TODO: Handle this case.
        // <JL> commenter pour travailler sur la phase attack
        switchState(GameStateMode.char_selection);

        break;
      case GameStateMode.projectile:
        // center camera on projectile
        this.camera.centerOn(currentWeapon.projectile.getPosition());

        // Stop stopWatch if non detonating projectile
        if (currentWeapon.detonationTime == -1) {
          if (stopWatch.isRunning) {
            stopWatch.stop();
            stopWatch.reset();
          }

          break;
        }

        // Time to detonate projectile
        if (stopWatch.elapsedMilliseconds > currentWeapon.detonationTime) {
          stopWatch.stop();
          stopWatch.reset();

          currentWeapon.applyImpact(
              currentWeapon.projectile, players, soundPlayer);
          this.removeProjectile(currentWeapon.projectile);
          currentWeapon = null;

          switchState(GameStateMode.char_selection);
        }

        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
    }

    // Check for dead players or dead characters and remove them
    for (int p = 0; p < players.length; p++) {
      for (int c = 0; c < players[p].length; c++) {
        //Check if the character is out of bounds
        if (!level.isInsideBounds(players[p][c].hitbox))
          players[p][c].isDead = true;

        // Check if the character is dead
        if (players[p][c].isDead) {
          this.removeCharacter(p, c);

          if (p == currentPlayer && c == currentCharacter)
            shouldEndTurn = true;

          c--;
        }
      }
      if (players[p].length == 0) {
        this.removePlayer(p);

        if (p == currentPlayer)
          shouldEndTurn = true;

        p--;
      }
    }

    // Check for end of the game
    if (players.length <= 1) {
      switchState(GameStateMode.over);
      return;
    }

    if (shouldEndTurn) switchState(GameStateMode.char_selection);

    currentCharIsDead = false;
  }

  void addCharacter(int playerId, Character character) {
    players[playerId].add(character);

    world.addCharacter(character);
    painter.addElement(character.drawer);
  }

  void removeCharacter(int playerId, int charID) {
    print("Character of player " + currentPlayer.toString() + " is dead");

    Character toRemove = players[playerId][charID];
    players[playerId].remove(toRemove);

    world.removeCharacter(toRemove);
    painter.removeElement(toRemove.drawer);

    if (playerId == currentPlayer && charID == currentCharacter)
      currentCharIsDead = true;
  }

  void addTerrainBlock(TerrainBlock block) {
    world.addTerrain(block);
    painter.addElement(block.drawer);
  }

  void removeTerrainBlock(TerrainBlock block) {
    world.removeTerrain(block);
    painter.removeElement(block.drawer);
  }

  void removePlayer(int playerID) {
    print("Player " + playerID.toString() + " is dead");

    players.removeAt(playerID);
    if (currentPlayer > playerID) currentPlayer--;
  }

  Character getCurrentCharacter() {
    if (currentCharIsDead ||
        players.length <= currentPlayer ||
        players[currentPlayer].length <= currentCharacter) return null;
    return players[currentPlayer][currentCharacter];
  }

  void addProjectile(Projectile projectile) {
    world.addProjectile(projectile);
    painter.addElement(projectile.drawer);
  }

  void removeProjectile(Projectile projectile) {
    world.removeProjectile(projectile);
    painter.removeElement(projectile.drawer);
  }

  void onTap(TapUpDetails details) {
    Offset tapPosition = GameUtils.absoluteToRelativeOffset(
        details.globalPosition, GameMain.size.height);

    //Take camera into account
    tapPosition += camera.position;

    print("OnTap : " + tapPosition.toString());

    switch (currentState) {
      case GameStateMode.char_selection:
        for (int i = 0; i < players[currentPlayer].length; i++)
          if (GameUtils.rectContains(
              GameUtils.extendRect(players[currentPlayer][i].hitbox, 10), tapPosition)) {
            currentCharacter = i;

            switchState(GameStateMode.moving);
            break;
          }
        break;

      case GameStateMode.moving:
        Character currentChar = getCurrentCharacter();

        //Touch event on the current character
        if (GameUtils.rectContains(currentChar.hitbox, tapPosition)) {
          if (!currentChar.isAirborne()) {
            currentChar.stopX();
            moveDestination = null;
            uiManager.removeMarker();
          }
        }

        //Touch event left of the current character
        else if (GameUtils.rectLeftOf(currentChar.hitbox, tapPosition)) {
          if (!currentChar.isAirborne()) {
            currentChar.beginWalking(Character.LEFT);
            this.startMoving(tapPosition);
          }
        }

        //Touch event right of the current character
        else if (GameUtils.rectRightOf(currentChar.hitbox, tapPosition)) {
          if (!currentChar.isAirborne()) {
            currentChar.beginWalking(Character.RIGHT);
            this.startMoving(tapPosition);
          }
        }
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        // For development only
        switchState(GameStateMode.moving);
        break;

      case GameStateMode.projectile:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
    }
  }

  void onPanStart(DragStartDetails details) {
    Character currentChar = getCurrentCharacter();
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(
        details.globalPosition, GameMain.size.height);
    Offset dragPositionCamera = dragPosition + camera.position;

    print("PanStart : " + dragPosition.toString());

    switch (currentState) {
      case GameStateMode.char_selection:
        this.cameraDragStartLocation = dragPosition;
        break;

      case GameStateMode.moving:
        //Drag on character. We extend the size of the hitbox due to imprecision
        //for coordinates in drag events
        if (GameUtils.rectContains(
            GameUtils.extendRect(currentChar.hitbox, 50), dragPositionCamera)) {
          if (currentChar.isAirborne()) return;
          currentChar.stop();

          characterJumping = true;
          jumpDragStartPosition = dragPositionCamera;

          uiManager.beginJump(GameUtils.getRectangleCenter(currentChar.hitbox));
        }
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        // Should color it in red
        launchDragStartPosition = dragPositionCamera;
        uiManager.beginJump(GameUtils.getRectangleCenter(currentChar.hitbox));
        break;

      case GameStateMode.projectile:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    Offset dragPosition = GameUtils.absoluteToRelativeOffset(
        details.globalPosition, GameMain.size.height);
    Offset dragPositionCamera = dragPosition + camera.position;

    switch (currentState) {
      case GameStateMode.char_selection:
        camera.position +=
            (this.cameraDragStartLocation - dragPosition) * CameraSpeed;
        this.cameraDragStartLocation = dragPosition;
        break;

      case GameStateMode.moving:
        if (characterJumping) {
          jumpDragEndPosition = dragPositionCamera;
          uiManager.updateJump(Character.getJumpSpeed(
              (dragPositionCamera - jumpDragStartPosition) *
                  JumpVectorNormalizer));
        }
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        launchDragEndPosition = dragPositionCamera;
        Offset tmp = currentWeapon.projectile.getLaunchSpeed(
            (dragPositionCamera - launchDragStartPosition) *
                LaunchVectorNormalizer);
        uiManager.updateJump(tmp);
        break;

      case GameStateMode.projectile:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
    }
  }

  void onPanEnd(DragEndDetails details) {
    Character currentChar = getCurrentCharacter();

    switch (currentState) {
      case GameStateMode.char_selection:
        break;

      case GameStateMode.moving:
        if (characterJumping) {
          currentChar.jump((jumpDragStartPosition - jumpDragEndPosition) *
              JumpVectorNormalizer);
          characterJumping = false;
          uiManager.endJump();
        }
        break;

      case GameStateMode.attacking:
        // TODO: Handle this case.
        // J.L

        this.addProjectile(currentWeapon.projectile);
        currentWeapon.fireProjectile(
            (launchDragStartPosition - launchDragEndPosition) *
                LaunchVectorNormalizer);
        uiManager.endJump();
        switchState(GameStateMode.projectile);
        stopWatch.start();
        uiManager.removeStaminaDrawer();
        break;

      case GameStateMode.projectile:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
    }
  }

  void onLongPress(LongPressStartDetails details) {
    Character currentChar = getCurrentCharacter();

    Offset longPressPosition = GameUtils.absoluteToRelativeOffset(
        details.globalPosition, GameMain.size.height);
    longPressPosition += camera.position;

    print("OnLongPress : " + longPressPosition.toString());

    switch (currentState) {
      case GameStateMode.char_selection:
        break;

      case GameStateMode.moving:
        if (GameUtils.rectContains(currentChar.hitbox, longPressPosition)) {
          if (currentChar.isAirborne()) return;
          currentChar.stop();

          //TODO : display armory
          print("Armory is here");
          // For the moment skip the selection to implement the rest
          Weapon selectedWeapon = currentChar.currentArsenal.arsenal[1];
          currentChar.currentArsenal.selectWeapon(selectedWeapon);
          currentWeapon = currentChar.currentArsenal.actualSelection;
          Offset pos = currentChar.getPosition();
          Offset hit = Offset(5, 5);
          ProjDHS boulet = new ProjDHS(
              pos,
              MutableRectangle(pos.dx, pos.dy, hit.dx, hit.dy),
              new Offset(0, 0),
              5.0,
              15,
              3000);

          currentWeapon.projectile = boulet;

          switchState(GameStateMode.attacking);

          // add weapon to be draw in a neutral position aligned with char

        }

        break;

      case GameStateMode.attacking:
        break;
      case GameStateMode.projectile:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
    }
  }

  /// Function used when starting the movement of a character. It place a marker
  /// on top of the terrain the closest to the destination
  void startMoving(Offset destination) {
    Offset markerPosition = destination;

    TerrainBlock closest = world.getClosestTerrainUnder(destination);
    if (closest != null && camera.isDisplayed(closest.hitBox))
      markerPosition = Offset(destination.dx, closest.hitBox.top);

    this.moveDestination = markerPosition;
    this.uiManager.addMarker(markerPosition);
  }

  /// Function that is called when we change the state of the game
  /// This is used to make sure that all the variables have the correct value at the start
  /// and end of the state
  void switchState(GameStateMode newState) {
    this.endState(currentState);
    this.startState(newState);

    currentState = newState;
  }

  void startState(GameStateMode newState) {
    switch (newState) {
      case GameStateMode.char_selection:
        this.currentPlayer = (currentPlayer + 1) % players.length;

        uiManager.removeStaminaDrawer();
        this.teamTurnText = uiManager.addText(
            teamNames[currentPlayer] + " team turn !", TextPositions.center, 50,
            duration: 3, fadeDuration: 3, ignoreCamera: true);
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
      case GameStateMode.projectile:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        uiManager.addText(
            "Game over!\nTouch to continue", TextPositions.center, 50,
            duration: 3, ignoreCamera: true);
        break;
    }
  }

  void endState(GameStateMode oldState) {
    switch (oldState) {
      case GameStateMode.char_selection:
        uiManager.removeText(this.teamTurnText);
        break;
      case GameStateMode.moving:
        uiManager.removeMarker();
        if (!currentCharIsDead && getCurrentCharacter() != null)
          getCurrentCharacter().stop();
        break;
      case GameStateMode.attacking:
        break;
      case GameStateMode.projectile:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
    }
  }
}
