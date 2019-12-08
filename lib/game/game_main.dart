import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/game_state.dart';
import 'package:info2051_2018/home.dart';

import 'level.dart';

class GameMain extends StatefulWidget {
  GameMain(this.levelJson, this.nbPlayers, this.nbCharacters);

  final String levelJson;
  final int nbPlayers;
  final int nbCharacters;
  static Size size;

  @override
  _GameMainState createState() =>
      new _GameMainState(levelJson, nbPlayers, nbCharacters);
}

class _GameMainState extends State<GameMain> {
  GameState state;
  int _callbackId;
  LevelPainter levelPainter;
  Duration lastTimeStamp;

  _GameMainState(String levelJson, int nbPlayers, int nbCharacters) {
    Level level = Level.fromJson(jsonDecode(levelJson));

    Camera camera = Camera(Offset(0, 0));

    this.levelPainter = LevelPainter(camera, level.size, showHitBoxes: true);
    levelPainter.addElement(BackgroundDrawer(level.size));

    state = GameState(
        nbPlayers, nbCharacters, levelPainter, level, camera);

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
      builder: (context) =>
      new AlertDialog(
        title: Text("Quit game"),
        content: Text("Quit game ?"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    GameMain.size = MediaQuery
        .of(context)
        .size;
    levelPainter.screenSize = Home.screenSizeLandscape;

    var onTapUp;
    if (state.currentState == GameStateMode.over) {
      onTapUp = (TapUpDetails details) {
        Navigator.of(context).pop();
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
      gestureDetector = GestureDetector(
          child: levelPainter.level
      );
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
}
