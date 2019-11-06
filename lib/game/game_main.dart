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
  GestureDetector gestureDetector;

  int _callbackId;

  var position = Offset(20.0, 40.0);
  var height = Character.hitboxSize.dy;
  var width = Character.hitboxSize.dx;

  LevelPainter levelPainter;

  _GameMainState() {
    levelPainter = new LevelPainter();

    //TODO delete dis
    levelPainter.addElement(new BackgroundDrawer());

    state = new GameState(1, 1, levelPainter);

    _scheduleFrame();
  }

  void _scheduleFrame() {
    _callbackId = SchedulerBinding.instance.scheduleFrameCallback(_update);
  }

  void _unscheduleFrame() {
    SchedulerBinding.instance.cancelFrameCallbackWithId(_callbackId);
  }

  void _update(Duration timestamp) {
    _scheduleFrame();

    state.update();
    if (!mounted)
      return;

    setState(() {
      position = state.getCurrentCharacter().position;
    });
  }

  void buildGestureDetector() {
    var rect = Rect.fromLTWH(position.dx, position.dy, width, height);

    this.gestureDetector = new GestureDetector(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    //TODO do things better
    GameMain.screenHeight = MediaQuery.of(context).size.height;

    //if(this.gestureDetector == null)
    buildGestureDetector();

    return new Scaffold(
      body: Container(child: this.gestureDetector),
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
  }

  @override
  dispose() {
    //Set orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _unscheduleFrame();
    super.dispose();
  }
}

//TODO Code totalement copié/collé du cours, faudrait voir ce que ca veut dire en vrai
class CanvasRectangle extends CustomPainter {
  Rect rect;
  Paint fill;
  Paint stroke;

  CanvasRectangle(this.rect, {Color fill, Color stroke}) {
    this.fill = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    if (stroke != null)
      this.stroke = Paint()
        ..color = stroke
        ..strokeCap = StrokeCap.square
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(rect, fill);
    if (stroke != null) {
      canvas.drawRect(rect, stroke);
    }
  }

  @override
  bool shouldRepaint(CanvasRectangle oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.fill != fill ||
      oldDelegate.stroke != stroke;
}
