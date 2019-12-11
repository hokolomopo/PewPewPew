import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/draw/text_drawer.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/util/team.dart';
import 'package:info2051_2018/game/ui_manager.dart';
import 'package:info2051_2018/game/util/game_statistics.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/world.dart';

import 'camera.dart';
import 'level.dart';

/// Enum to describe the current state of the game
enum GameStateMode {
  char_selection,
  moving,
  attacking,
  weapon_selection,
  projectile,
  explosion, //TODO remove this state
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

  List<Team> players = new List();
  GameStats gameStats = GameStats(null, Map());

  World world;
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

  bool currentCharIsDead = false;

  /// GameStateMode.attacking variables
  bool ammoLaunching;
  Offset launchDragStartPosition;
  Offset launchDragEndPosition;
  Weapon currentWeapon;

  /// GameStateMode.projectile variables
  Stopwatch stopWatch = Stopwatch();

  /// GameStateMode.explosion variables
  List<MyAnimation> currentAnimations = List();

  GameState(int numberOfPlayers, int numberOfCharacters, this.painter,
      this.level, this.camera, this.world) {

    uiManager = UiManager(painter);

    level.spawnPoints.shuffle();

    for (TerrainBlock block in level.terrain) this.addTerrainBlock(block);

    for (int i = 0; i < numberOfPlayers; i++) {
      Team t = Team(i, teamNames[i], numberOfCharacters);
      players.add(t);

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

    bool shouldEndTurn = false;

    // Before going through States checking, check if there is any explosion
    // to remove from the painters
    for (MyAnimation a in currentAnimations)
      if (a.hasEnded())
      this.removeAnimation(a);

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
                      currentChar.hitbox.left +
                          currentChar.hitbox.width * 2 / 3) ||
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

        break;

      case GameStateMode.weapon_selection:
        break;

      case GameStateMode.projectile:
        // center camera on projectile
        this.camera.centerOn(currentWeapon.projectile.getPosition());

        // check if the projectile is out of bounds
        if (!level.isInsideBounds(currentWeapon.projectile)) {

          resetStopWatch();
          this.removeProjectile(currentWeapon.projectile);
          switchState(GameStateMode.cinematic);
        }

        // If non explosiveProjectile, then it is an collidable one
        else if (!(currentWeapon.projectile is ExplosiveProjectile)) {
          // Checking if a collidable projectile has
          // intersect a hitbox (terrain or character)
          if(world.checkCollidableProj(getCurrentCharacter()))
            currentWeapon.proceedToEnd(this);
        }
        // Check if time to detonate
        else if (stopWatch.elapsedMilliseconds > currentWeapon.detonationDelay) {
          resetStopWatch();
          currentWeapon.proceedToEnd(this);
        }

        break;
      case GameStateMode.explosion:
        break;
      case GameStateMode.cinematic:
        // If the last attack has knocked back someone, film until everyone stop moving
        bool isSomeoneMoving = false;
        bool isSomeoneMovingOnScreen = false;
        bool isSomeoneDying = false;
        Character movingCharacter;
        for (Team v in players) {
          for (Character c in v.characters) {
            if (c.isDying || c.isDead) isSomeoneDying = true;
            if (c.isMoving()) {
              if (camera.isDisplayed(c.hitbox)) isSomeoneMovingOnScreen = true;
              isSomeoneMoving = true;
              movingCharacter = c;
            }
          }
        }

        // If the character moving is not on screen, mode the camera to him
        if (isSomeoneMoving && !isSomeoneMovingOnScreen)
          camera.centerOn(movingCharacter.getPosition());

        // If no one is moving, go to next player
        else if (!isSomeoneMoving && !isSomeoneDying)
          switchState(GameStateMode.char_selection);

        break;
      case GameStateMode.over:
        break;
    }

    // Check for dead players or dead characters and remove them
    for (int p = 0; p < players.length; p++) {
      for (int c = 0; c < players[p].length; c++) {
        //Check if the character is out of bounds
        // Don't use character.kill function to skip death animation
        if (!level.isInsideBounds(players[p].getCharacter(c))) {
          players[p].getCharacter(c).isDead = true;
          players[this.currentPlayer]
              .updateStats(TeamStat.killed, 1, teamTakingAttack: p);
        }

        // Check if the character is dead
        if (players[p].getCharacter(c).isDead) {
          this.removeCharacter(p, c);

          if (p == currentPlayer && c == currentCharacter) shouldEndTurn = true;

          c--;
        }
      }
      if (players[p].length == 0) {
        this.removePlayer(p);

        if (p == currentPlayer) shouldEndTurn = true;

        p--;
      }
    }

    // Check for end of the game
    if (currentState != GameStateMode.cinematic && players.length <= 1) {
      switchState(GameStateMode.over);
      return;
    }

    if (shouldEndTurn) switchState(GameStateMode.char_selection);

    currentCharIsDead = false;
  }

  void addCharacter(int playerId, Character character) {
    players[playerId].addCharacter(character);

    world.addCharacter(character);
    painter.addElement(character.drawer);
  }

  void removeCharacter(int playerId, int charID) {
    print("Character of player " + currentPlayer.toString() + " is dead");

    Character toRemove = players[playerId].getCharacter(charID);
    players[playerId].removeCharacter(toRemove);

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
    this.computeStats(players[playerID]);

    players.removeAt(playerID);
    if (currentPlayer > playerID) currentPlayer--;
  }

  Character getCurrentCharacter() {
    if (currentCharIsDead ||
        players.length <= currentPlayer ||
        players[currentPlayer].length <= currentCharacter) return null;
    return players[currentPlayer].getCharacter(currentCharacter);
  }

  void addProjectile(Projectile projectile) {
    world.addProjectile(projectile);
    painter.addElement(projectile.drawer);
  }

  void removeProjectile(Projectile projectile) {
    world.removeProjectile(projectile);
    painter.removeElement(projectile.drawer);
  }

  // TODO put add and remove line for currentAnimations list
  void addAnimation(MyAnimation animation){
    currentAnimations.add(animation);
    painter.addElement(animation.drawer);
  }

  void removeAnimation(MyAnimation animation) {
    currentAnimations.remove(animation);
    painter.removeElement(animation.drawer);
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
              GameUtils.extendRect(
                  players[currentPlayer].getCharacter(i).hitbox, 10),
              tapPosition)) {
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
//        switchState(GameStateMode.moving);
        break;

      case GameStateMode.projectile:
        break;

      case GameStateMode.weapon_selection:
        Arsenal currentArsenal = getCurrentCharacter().currentArsenal;
        Weapon selectedWeapon = currentArsenal.getWeaponAt(tapPosition);
        if (selectedWeapon != null) {
          currentArsenal.selectWeapon(selectedWeapon);
          currentWeapon = currentArsenal.currentSelection;
          if(currentWeapon == null)
            print("wtf currentWeapon = currentArsenal.currentSelection ");
          // TODO correctly assign projectile to weapon (certainly in overridable method)
//          Offset pos = getCurrentCharacter().getPosition();
//          Offset hit = Offset(5, 5);
//          ProjDHS projDHS = new ProjDHS(
//              pos, MutableRectangle(pos.dx, pos.dy, hit.dx, hit.dy));
//          currentWeapon.projectile = projDHS;

          switchState(GameStateMode.attacking);
        }
        break;
      case GameStateMode.explosion:
        break;

      case GameStateMode.projectile:
        break;
      default:
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
        if(currentWeapon == null){
          print("PanStart, currentWeapon == null");
          return;
        }

        currentWeapon.prepareFiring(currentChar.getPosition());
        launchDragStartPosition = dragPositionCamera;

        uiManager.beginJump(GameUtils.getRectangleCenter(currentChar.hitbox));
        break;

      case GameStateMode.explosion:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
      default:
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
        if (currentWeapon == null || currentWeapon.projectile == null)
          return;

        // Compute the launch vector and the angle of launching
        Offset launchVector = dragPositionCamera - launchDragStartPosition;
        Offset tmp = currentWeapon.projectile.getLaunchSpeed(launchVector * LaunchVectorNormalizer);
        currentWeapon.drawer.angle = atan(launchVector.dy / launchVector.dx);
        uiManager.updateJump(tmp);

        // Change the character orientation following the direction of aiming
        if(launchVector.dx < 0)
          getCurrentCharacter().directionFaced = Character.RIGHT;
        else
          getCurrentCharacter().directionFaced = Character.LEFT;

        break;
      case GameStateMode.explosion:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
      default:
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

        uiManager.endJump();

        // If we ended the drag on the character, cancel the attack
        if(currentChar != null && currentChar.hitbox.containsPoint(GameUtils.toPoint(launchDragEndPosition))){
          switchState(GameStateMode.moving);
        }

        if (currentWeapon == null || currentWeapon.projectile == null) return;
        Projectile p = currentWeapon.fireProjectile((launchDragStartPosition - launchDragEndPosition) *
                LaunchVectorNormalizer);
        currentWeapon.ammunition -= 1;
        this.addProjectile(p);

        if(p is ExplosiveProjectile)
          stopWatch.start();


        switchState(GameStateMode.projectile);
        break;

      case GameStateMode.explosion:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        break;
      default:
        break;
    }
  }

  void onLongPress(LongPressStartDetails details) {
    Character currentChar = getCurrentCharacter();

    Offset longPressPosition = GameUtils.absoluteToRelativeOffset(
        details.globalPosition, GameMain.size.height);
    longPressPosition += camera.position;

    print("OnLongPress : " + longPressPosition.toString());

    print(currentState.toString());

    switch (currentState) {
      case GameStateMode.char_selection:
        //Select the taped player
        for (int i = 0; i < players[currentPlayer].length; i++)
          if (GameUtils.rectContains(
              GameUtils.extendRect(
                  players[currentPlayer].getCharacter(i).hitbox, 10), longPressPosition)) {
            currentCharacter = i;

            switchState(GameStateMode.moving);
            break;
          }
        break;

      case GameStateMode.moving:
      case GameStateMode.attacking:

        if (GameUtils.rectContains(GameUtils.extendRect(currentChar.hitbox, 10), longPressPosition)) {
          if (currentChar.isAirborne()) return;
          currentChar.stop();

          switchState(GameStateMode.weapon_selection);
        }
        break;

      case GameStateMode.weapon_selection:
        break;

      case GameStateMode.projectile:
        break;
      case GameStateMode.explosion:
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

        uiManager.addStaminaDrawer(getCurrentCharacter());
        break;
      case GameStateMode.attacking:
        break;

      case GameStateMode.weapon_selection:
        Character currentChar = getCurrentCharacter();
        Arsenal currentArsenal = currentChar.currentArsenal;

        currentArsenal.showWeaponSelection(currentChar.hitbox);

        for (Weapon weapon in currentArsenal.arsenal) {
          painter.addElement(weapon.drawer);
        }

        break;

      case GameStateMode.projectile:
        uiManager.removeStaminaDrawer();
        break;
      case GameStateMode.explosion:
        break;
      case GameStateMode.cinematic:
        break;
      case GameStateMode.over:
        // Compute stats for last team
        if (players.length == 1) {
          this.computeStats(players[0]);
          gameStats.winningTeam = players[0].teamName;

          uiManager.addText(
              "Team " + players[0].teamName + " won !\nTouch to continue",
              TextPositions.center,
              50,
              duration: 3,
              ignoreCamera: true);
        }
        // No players left, it's a tie
        else {
          uiManager.addText(
              "Game over!\nTouch to continue", TextPositions.center, 50,
              duration: 3, ignoreCamera: true);
        }
        break;
    }
  }

  void endState(GameStateMode oldState) {
    switch (oldState) {
      case GameStateMode.char_selection:
        uiManager.removeText(this.teamTurnText);
        getCurrentCharacter().refillStamina();
        break;
      case GameStateMode.moving:
        uiManager.removeMarker();
        if (!currentCharIsDead && getCurrentCharacter() != null)
          getCurrentCharacter().stop();
        break;
      case GameStateMode.attacking:
        break;

      case GameStateMode.weapon_selection:
        Arsenal curArsenal = getCurrentCharacter().currentArsenal;
        for (Weapon weapon in curArsenal.arsenal) {
          if (weapon != curArsenal.currentSelection) {
            painter.removeElement(weapon.drawer);
          }
        }
        break;

      case GameStateMode.projectile:
        break;
      case GameStateMode.explosion:
        break;
      case GameStateMode.cinematic:
        if(currentWeapon != null)
          painter.removeElement(currentWeapon.drawer);
        currentWeapon = null;
        print("Set currentWeapon to null");
        break;
      case GameStateMode.over:
        break;
    }
  }

  /// Compute the stats of a team and save it
  /// Should be called when a team is eliminated
  void computeStats(Team t) {
    Map<TeamStat, double> teamStats = t.computeStats();
    gameStats.statistics.putIfAbsent(t.teamName, () => teamStats);
  }

  resetStopWatch() {
    stopWatch.stop();
    stopWatch.reset();
  }
}
