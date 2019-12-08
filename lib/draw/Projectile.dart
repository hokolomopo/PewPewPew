import 'dart:ui';

import 'paint_constants.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/util/utils.dart';

// TODO Remove and Merge this with Draw Character File

class ProjectileDrawer extends CustomDrawer{
  Projectile projectile;

  ProjectileDrawer(String gifPath, this.projectile,
      {Size screenSize, Size size = const Size(10, 10)})
      : super(size, gifPath, screenSize: screenSize);

  @override
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {
    double left =
    GameUtils.relativeToAbsoluteDist(projectile.position.dx, size.height);
    double top =
    GameUtils.relativeToAbsoluteDist(projectile.position.dy, size.height);
    double actualWidth = GameUtils.relativeToAbsoluteDist(actualSize.width, size.height);
    double actualHeight = GameUtils.relativeToAbsoluteDist(actualSize.height, size.height);

    if (showHitBoxes) {
      canvas.drawRect(Rect.fromLTWH(left, top, actualWidth, actualHeight),
          debugShowHitBoxesPaint);
    }

    canvas.drawImage(fetchNextFrame(), Offset(left, top), Paint());

  }

}