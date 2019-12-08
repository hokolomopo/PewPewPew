import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_state.dart';
import 'package:info2051_2018/home.dart';

import 'level.dart';

class GameMain extends StatefulWidget {
  GameMain({Key key, this.level}) : super(key: key);

  final String level;
  static Size size;

  @override
  _GameMainState createState() => new _GameMainState(level);
}

class _GameMainState extends State<GameMain> {
  //TODO delete dis, put it in a file and read it
  String levelJson;

  //'{"terrain":[{"hitBox":{"x":100.0,"y":110.0,"h":90.0,"w":50.0}},{"hitBox":{"x":150.0,"y":135.0,"h":65.0,"w":100.0}},{"hitBox":{"x":250.0,"y":150.0,"h":50.0,"w":100.0}},{"hitBox":{"x":350.0,"y":135.0,"h":65.0,"w":100.0}},{"hitBox":{"x":450.0,"y":110.0,"h":90.0,"w":50.0}},{"hitBox":{"x":175.0,"y":85.0,"h":10.0,"w":60.0}},{"hitBox":{"x":250.0,"y":65.0,"h":10.0,"w":100.0}},{"hitBox":{"x":365.0,"y":85.0,"h":10.0,"w":60.0}},{"hitBox":{"x":270.0,"y":110.0,"h":10.0,"w":60.0}}],"sizeX":600.0,"sizeY":200.0,"spawnPoints":[{"dx":280.0,"dy":10.0},{"dx":130.0,"dy":10.0},{"dx":235.0,"dy":10.0},{"dx":265.0,"dy":10.0},{"dx":160.0,"dy":10.0},{"dx":175.0,"dy":10.0},{"dx":145.0,"dy":10.0},{"dx":250.0,"dy":10.0},{"dx":100.0,"dy":10.0},{"dx":310.0,"dy":10.0},{"dx":115.0,"dy":10.0},{"dx":220.0,"dy":10.0},{"dx":325.0,"dy":10.0},{"dx":205.0,"dy":10.0},{"dx":190.0,"dy":10.0},{"dx":295.0,"dy":10.0}]}';
  GameState state;

  int _callbackId;

  var position = Offset(20.0, 40.0);
  var height = Character.hitboxSize.dy;
  var width = Character.hitboxSize.dx;

  LevelPainter levelPainter;

  Duration lastTimeStamp;

  _GameMainState(this.levelJson) {
    Level level = Level.fromJson(jsonDecode(levelJson));

    Camera camera = Camera(Offset(0, 0));

    this.levelPainter = LevelPainter(camera, level.size, showHitBoxes: true);
    levelPainter.addElement(BackgroundDrawer(level.size));

    state = GameState(2, 2, levelPainter, level, camera);

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

    state.update(timeElapsed.toDouble() / 1000);
    if (!mounted) return;

    setState(() {
      position = position * 1;
    });
    _scheduleFrame();
  }

  Future<bool> _mayExitGame() {
    print("on will pop");
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
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    GameMain.size = MediaQuery.of(context).size;
    levelPainter.screenSize = Home.screenSizeLandscape;
    int i = 0;

    return WillPopScope(
      onWillPop: _mayExitGame,
      child: new Scaffold(
        body: Container(
            child: GestureDetector(
                onTapUp: (details) {
                  state.onTap(details);
                },
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
                child: levelPainter.level)),
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
