import 'dart:ui';

import 'paint_constants.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/util/utils.dart';

// TODO Remove and Merge this with Draw Character File (maybe create a new abstract class ImagedCustomDrawer ?)

class ProjectileDrawer extends CustomDrawer{
  Projectile projectile;

  ProjectileDrawer(String gifPath, this.projectile,
      {Size size = const Size(5, 5)})
      : super(size, gifPath);

  @override
  bool isReady(Size screenSize) {
    super.isReady(screenSize);
    return imgAndGif.containsKey(gifPath) &&
        imgAndGif[gifPath].containsKey(relativeSize) &&
        imgAndGif[gifPath][relativeSize] != null &&
        imgAndGif[gifPath][relativeSize].fetchNextFrame() != null;
  }

  void paint(
      Canvas canvas, Size screenSize, showHitBoxes, Offset cameraPosition) {
    double left = GameUtils.relativeToAbsoluteDist(
        projectile.position.dx, screenSize.height);
    double top = GameUtils.relativeToAbsoluteDist(
        projectile.position.dy, screenSize.height);

    if (showHitBoxes) {
      canvas.drawRect(
          Rect.fromLTWH(left, top, actualSize.width, actualSize.height),
          debugShowHitBoxesPaint);
    }

    // If frictionFactor == 1 means that we have to stay with the same frame
    if(projectile.animationStopped)
      imgAndGif[gifPath][relativeSize].lockAnimation = true;

      canvas.drawImage(fetchNextFrame(), Offset(left, top), Paint());

  }

}