import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/game_state.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/world.dart';
import 'package:info2051_2018/home.dart';
import 'package:info2051_2018/stats_screen.dart';

import '../quickplay_widgets.dart';
import '../sound_player.dart';
import 'level.dart';

class GameMain extends StatefulWidget {
  static const routeName = '/GameMain';

  static Map<String, WeaponStats> availableWeapons = Map();

  GameMain(this.terrain, this.nbPlayers, this.nbCharacters,
      List<WeaponStats> weapons) {
    for (WeaponStats stat in weapons)
      availableWeapons.putIfAbsent(stat.weaponName, () => stat);
  }

  final Terrain terrain;
  final int nbPlayers;
  final int nbCharacters;
  static Size size;

  @override
  _GameMainState createState() =>
      new _GameMainState(terrain, nbPlayers, nbCharacters);
}

class _GameMainState extends State<GameMain> with WidgetsBindingObserver {
  GameState state;
  int _callbackId;
  LevelPainter levelPainter;
  Duration lastTimeStamp;

  _GameMainState(Terrain terrain, int nbPlayers, int nbCharacters) {
    Level level = Level.fromJson(jsonDecode(terrain.levelObject));
    level.color = HexColor(terrain.terrainColor);

    Camera camera = Camera(Offset(0, 0));
    AssetsManager assetManager =
        AssetsManager(level.size, terrain.backgroundPath, nbPlayers);
    this.levelPainter =
        LevelPainter(camera, level.size, assetManager);
    levelPainter.addElement(BackgroundDrawer(level.size, AssetId.background));

    state = GameState(nbPlayers, nbCharacters, levelPainter, level, camera,
        World(gravityForce: terrain.gravity));

    _scheduleFrame();
  }

  /// Schedule an execution of the _update function for the next frame
  void _scheduleFrame() {
    _callbackId = SchedulerBinding.instance.scheduleFrameCallback(_update);
  }

  /// Unschedule an execution of the _update function for the next frame
  void _unscheduleFrame() {
    SchedulerBinding.instance.cancelFrameCallbackWithId(_callbackId);
  }

  /// Function called at each frame.
  /// Update the GameState and re-draw the game on the screen
  void _update(Duration timestamp) {
    int timeElapsed =
        lastTimeStamp == null ? 0 : (timestamp - lastTimeStamp).inMilliseconds;
    lastTimeStamp = timestamp;
    timeElapsed = min(100, timeElapsed);

    if (levelPainter.gameStarted) {
      state.update(timeElapsed.toDouble() / 1000);
    }
    if (!mounted) return;

    setState(() {});
    _scheduleFrame();
  }

  Future<bool> _mayExitGame() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text("Quit game"),
            content: Text("Quit game ?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              FlatButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, Home.routeName, (Route<dynamic> route) => false),
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    GameMain.size = MediaQuery.of(context).size;
    levelPainter.screenSize = Home.screenSizeLandscape;
    levelPainter.assetsManager.init(Home.screenSizeLandscape);

    var onTapUp;
    if (state.currentState == GameStateMode.over) {
      onTapUp = (TapUpDetails details) {
        Navigator.pushNamedAndRemoveUntil(
            context, StatsScreen.routeName, (Route<dynamic> route) => false,
            arguments: state.gameStats);
      };
    } else {
      onTapUp = (TapUpDetails details) {
        state.onTap(details);
      };
    }

    var gestureDetector;
    if (levelPainter.gameStarted) {
      gestureDetector = GestureDetector(
          onTapUp: onTapUp,
          onPanStart: (details) {
            state.onPanStart(details);
          },
          onPanUpdate: (details) {
            state.onPanUpdate(details);
          },
          onPanEnd: (details) {
            state.onPanEnd(details);
          },
          onLongPressStart: (details) {
            state.onLongPress(details);
          },
          child: levelPainter.level);
    } else {
      gestureDetector = GestureDetector(child: levelPainter.level);
    }

    return WillPopScope(
      onWillPop: _mayExitGame,
      child: new Scaffold(
        body: Container(
          child: gestureDetector,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    //Set orientation to landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    //Disable Device status bar
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  dispose() {
    //Set orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    //Enable Device status bar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    _unscheduleFrame();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        SoundPlayer.getInstance().resumeLoopMusic();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        SoundPlayer.getInstance().pauseLoopMusic();
        break;
    }
  }

}
