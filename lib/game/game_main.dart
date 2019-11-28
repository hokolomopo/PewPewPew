import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_state.dart';
import 'package:info2051_2018/game/terrain.dart';

import 'level.dart';


class GameMain extends StatefulWidget {
  GameMain({Key key, this.level}) : super(key: key);

  final String level;
  static Size size;

  @override
  _GameMainState createState() => new _GameMainState(level);
}

class _GameMainState extends State<GameMain> {

  GameState state;

  int _callbackId;

  var position = Offset(20.0, 40.0);
  var height = Character.hitboxSize.dy;
  var width = Character.hitboxSize.dx;

  LevelPainter levelPainter;

  Duration lastTimeStamp;

  _GameMainState(String levelName) {
    //TODO delete dis and load level
    Level level = Level();
    level.size = Size(400, 150);
    level.addTerrain(new TerrainBlock(-100, 70, 20000, 10));
    level.addTerrain(new TerrainBlock(150, 0, 10, 20000));
    level.addTerrain(new TerrainBlock(50, 40, 50, 10));
    for(int i = 0;i < 16;i++)
      level.spawnPoints.add(Offset(15.0*i, 10));

    Camera camera = Camera(Offset(0,0));

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
  /// Update the GameState and re-draw the gae on the screen
  void _update(Duration timestamp) {
    _scheduleFrame();

    int timeElapsed = lastTimeStamp == null ? 0 : (timestamp - lastTimeStamp).inMilliseconds;
    lastTimeStamp = timestamp;

    state.update(timeElapsed.toDouble() / 1000);
    if (!mounted)
      return;

    setState(() {
      position = position * 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    GameMain.size = MediaQuery.of(context).size;

    return new Scaffold(
      body: Container(
          child :GestureDetector(
              onTapDown: (details) {
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
              child: levelPainter.level
          )
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
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);

    _unscheduleFrame();
    super.dispose();
  }
}