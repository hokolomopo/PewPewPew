import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class GameMain extends StatefulWidget {
  GameMain({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GameMainState createState() => new _GameMainState();
}

class _GameMainState extends State<GameMain> {
  var position = Offset(20.0, 40.0);
  var height = 100.0;
  var width = 100.0;


  _GameMainState(){
    _scheduleFrame();
  }

  void _scheduleFrame() {
    SchedulerBinding.instance.scheduleFrameCallback(_update);
  }

  void _update(Duration timestamp) {
    _scheduleFrame();
    if(!mounted)
      return;
    setState(() {
      position += new Offset(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    var rect = Rect.fromLTWH(position.dx, position.dy, width, height);
    return new Scaffold(
      body: CustomPaint(
        size: Size.infinite,
        painter: CanvasRectangle(
            rect,
            fill: Colors.blue,
            stroke: null),
      ),
    );
  }
}


//Code totalement copié/collé du cours, faudrait voir ce que ca veut dire en vrai
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
