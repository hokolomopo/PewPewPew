import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_state.dart';

class GameMain extends StatefulWidget {
  GameMain({Key key, this.title}) : super(key: key);

  final String title;
  static double screenHeight;

  @override
  _GameMainState createState() => new _GameMainState();
}

class _GameMainState extends State<GameMain> {
  GameState state;

  int _callbackId;

  var position = Offset(20.0, 40.0);
  var height = Character.hitboxSize.dy;
  var width = Character.hitboxSize.dx;

  LevelPainter levelPainter;

  Duration lastTimeStamp;

  _GameMainState() {
    this.levelPainter = LevelPainter(showHitBoxes: true);
    //TODO delete dis
    levelPainter.addElement(BackgroundDrawer());

    state = GameState(2, 2, levelPainter);

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

    Duration timeElapsed = lastTimeStamp == null ? timestamp : timestamp - lastTimeStamp;
    lastTimeStamp = timestamp;
    print(timeElapsed.inMilliseconds);

    state.update();
    if (!mounted)
      return;

    setState(() {
      position = position * 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    //TODO do things better
    GameMain.screenHeight = MediaQuery.of(context).size.height;

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